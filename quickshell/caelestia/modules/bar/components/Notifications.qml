import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property DrawerVisibilities visibilities

    implicitWidth: icon.implicitHeight + Tokens.padding.small
    implicitHeight: icon.implicitHeight

    StateLayer {
        // Cursed workaround to make the height larger than the parent
        anchors.fill: undefined
        anchors.centerIn: parent
        implicitWidth: implicitHeight
        implicitHeight: icon.implicitHeight + Tokens.padding.small
        radius: Tokens.rounding.full
        onClicked: root.visibilities.sidebar = !root.visibilities.sidebar
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        text: "notifications"
        color: Colours.palette.m3secondary
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
        fill: root.visibilities.sidebar ? 1 : 0

        Behavior on fill {
            Anim {}
        }
    }
}
