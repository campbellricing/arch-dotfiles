import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.services

Item {
    id: root

    readonly property var batteries: [...UPower.devices.values].filter(d => d.isLaptopBattery).sort((a, b) => a.nativePath.localeCompare(b.nativePath))
    readonly property bool split: batteries.length > 1

    readonly property real tankWidth: Config.dashboard.performance.showCpu || (Config.dashboard.performance.showGpu && Gpu.type !== Gpu.None) || Config.dashboard.performance.showStorage || Config.dashboard.performance.showMemory ? Tokens.sizes.dashboard.perfBattWidth : Tokens.sizes.dashboard.perfBattWidthSingle

    implicitWidth: tankWidth
    implicitHeight: Tokens.sizes.dashboard.perfBattHeight

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.small

        Repeater {
            model: ScriptModel {
                values: root.split ? root.batteries : [UPower.displayDevice]
            }

            Tank {}
        }
    }

    component Tank: StyledClippingRect {
        id: tank

        required property UPowerDevice modelData
        readonly property UPowerDevice device: modelData
        readonly property string label: root.split ? qsTr("Battery #%1").arg(device.nativePath.replace(/\D/g, "")) : qsTr("Battery")
        property real animPerc: device.percentage

        Layout.fillWidth: true
        Layout.fillHeight: true

        color: Colours.palette.m3secondaryContainer
        radius: Tokens.rounding.large

        Behavior on animPerc {
            Anim {}
        }

        Contents {
            id: layout

            anchors.fill: parent
            anchors.margins: Tokens.padding.medium

            device: tank.device
            label: tank.label
            accentColour: Colours.palette.m3primary
            textColour: Colours.palette.m3onSurface
            subTextColour: Colours.palette.m3onSurfaceVariant
        }

        StyledRect {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: parent.height * tank.animPerc

            color: Colours.palette.m3secondary
            radius: Tokens.rounding.extraSmall
            clip: true

            Contents {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: layout.anchors.margins
                height: layout.height

                device: tank.device
                label: tank.label
                accentColour: Colours.palette.m3primaryContainer
                textColour: Colours.palette.m3onSecondary
                subTextColour: Colours.palette.m3secondaryContainer
            }
        }
    }

    component Contents: ColumnLayout {
        id: contents

        required property UPowerDevice device
        required property string label
        required property color accentColour
        required property color textColour
        required property color subTextColour
        readonly property bool charging: [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(device.state)

        spacing: 0

        MaterialIcon {
            Layout.leftMargin: -Tokens.padding.extraSmall
            text: "battery_full"
            color: contents.accentColour
            fontStyle: Tokens.font.icon.large
        }

        StyledText {
            Layout.fillWidth: true
            text: contents.label
            color: contents.textColour
            font: Tokens.font.body.medium
            elide: Text.ElideRight
        }

        Item {
            Layout.fillHeight: true
        }

        StyledText {
            Layout.alignment: Qt.AlignRight
            text: {
                if (contents.device.state === UPowerDeviceState.FullyCharged)
                    return qsTr("Full");

                if (contents.charging)
                    return qsTr("Charging");

                const s = contents.device.timeToEmpty;
                if (s === 0)
                    return qsTr("...");

                const hr = Math.floor(s / 3600);
                const min = Math.floor((s % 3600) / 60);
                if (hr > 0)
                    return `${hr}h ${min}m`;

                return `${min}m`;
            }
            color: contents.subTextColour
            font: Tokens.font.body.small
            animate: true
        }

        RowLayout {
            Layout.topMargin: -Tokens.padding.extraSmall
            Layout.bottomMargin: -Tokens.padding.small
            Layout.rightMargin: -Tokens.padding.extraSmall
            Layout.alignment: Qt.AlignRight
            spacing: Tokens.spacing.extraSmall

            MaterialIcon {
                text: "bolt"
                color: contents.accentColour
                fontStyle: Tokens.font.icon.large
                fill: 1

                scale: contents.charging ? 1 : 0
                opacity: contents.charging ? 1 : 0

                Behavior on scale {
                    Anim {
                        type: Anim.FastSpatial
                    }
                }

                Behavior on opacity {
                    Anim {
                        type: Anim.FastEffects
                    }
                }
            }

            StyledText {
                text: `${Math.round(contents.device.percentage * 100)}%`
                color: contents.accentColour
                font: Tokens.font.headline.medium
            }
        }
    }
}
