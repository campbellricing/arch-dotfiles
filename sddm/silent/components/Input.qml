// Caelestia-style input for SilentSDDM.
// Drop-in replacement for components/Input.qml — same API (placeholder,
// input, isPassword, splitBorderRadius, text, icon, enabled,
// showSubmitButton), restyled to match caelestia's lock screen
// (modules/lock/center/PasswordInput.qml + InputField.qml):
//   - pill-shaped surface-container field that grows while typing
//   - password characters rendered as shapes that pop in and settle
//     into round dots
//   - centered placeholder that fades out on input
//   - enter button that fills with the primary colour once there is text
// Colours come from the theme config: PasswordInput.content-color /
// background-color for the field, LoginButton.active-background-color /
// active-content-color for the filled enter button.

import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: input

    signal accepted

    property string placeholder: ""
    property alias input: textField
    property bool isPassword: false
    property bool splitBorderRadius: false // unused: caelestia style is always a full pill
    property alias text: textField.text
    property string icon: ""
    property bool enabled: true
    property bool showSubmitButton: false

    readonly property color contentColor: Config.passwordInputContentColor
    readonly property color placeholderColor: Qt.rgba(contentColor.r, contentColor.g, contentColor.b, 0.55)
    readonly property real dotBase: Math.max(8, Config.passwordInputFontSize * Config.generalScale)
    readonly property real edgePadding: 4 * Config.generalScale
    readonly property real fullWidth: Config.passwordInputWidth * Config.generalScale
    // Width when the field is empty: just enough for icon + placeholder + button,
    // like caelestia's collapsed state
    readonly property real compactWidth: iconContainer.width + placeholderMetrics.width
        + (submitButton.visible ? submitButton.width : 0) + edgePadding * 2 + 20 * Config.generalScale

    implicitWidth: isPassword && text.length === 0 ? Math.min(fullWidth, compactWidth) : fullWidth
    implicitHeight: Config.passwordInputHeight * Config.generalScale
    width: implicitWidth
    height: implicitHeight

    Behavior on implicitWidth {
        enabled: Config.enableAnimations
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuint
        }
    }

    TextMetrics {
        id: placeholderMetrics
        text: input.placeholder
        font.family: Config.passwordInputFontFamily
        font.pixelSize: Math.max(8, Config.passwordInputFontSize * Config.generalScale)
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Config.passwordInputBackgroundColor
        opacity: Config.passwordInputBackgroundOpacity
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "transparent"
        visible: Config.passwordInputBorderSize > 0
        border.width: Config.passwordInputBorderSize * Config.generalScale
        border.color: Config.passwordInputBorderColor
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: textField.forceActiveFocus()
    }

    Item {
        id: iconContainer
        visible: Config.passwordInputDisplayIcon
        width: visible ? parent.height : 0
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: input.edgePadding

        Image {
            id: fieldIcon
            source: input.icon
            anchors.centerIn: parent
            width: Math.max(1, Config.passwordInputIconSize * Config.generalScale)
            height: width
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            visible: false
        }

        MultiEffect {
            source: fieldIcon
            anchors.fill: fieldIcon
            colorization: 1
            colorizationColor: input.contentColor
            opacity: input.enabled ? 0.8 : 0.3
            Behavior on opacity {
                enabled: Config.enableAnimations
                NumberAnimation {
                    duration: 250
                }
            }
        }
    }

    Item {
        id: middleArea
        anchors.left: iconContainer.right
        anchors.right: submitButton.visible ? submitButton.left : parent.right
        anchors.rightMargin: submitButton.visible ? 0 : parent.height / 2
        height: parent.height
        clip: true

        TextField {
            id: textField
            anchors.fill: parent
            enabled: input.enabled
            echoMode: input.isPassword ? TextInput.Password : TextInput.Normal
            passwordCharacter: Config.passwordInputMaskedCharacter
            // Password glyphs are drawn as animated dots below; hide the real ones
            color: input.isPassword ? "transparent" : input.contentColor
            activeFocusOnTab: true
            selectByMouse: !input.isPassword
            cursorDelegate: Item {}
            horizontalAlignment: TextField.AlignHCenter
            verticalAlignment: TextField.AlignVCenter
            font.family: Config.passwordInputFontFamily
            font.pixelSize: Math.max(8, Config.passwordInputFontSize * Config.generalScale)
            background: Item {}
            onAccepted: input.accepted()
        }

        Text {
            id: placeholderText
            anchors.centerIn: parent
            text: input.placeholder
            color: input.placeholderColor
            font.family: Config.passwordInputFontFamily
            font.pixelSize: Math.max(8, Config.passwordInputFontSize * Config.generalScale)
            opacity: input.text.length === 0 ? 1 : 0
            Behavior on opacity {
                enabled: Config.enableAnimations
                NumberAnimation {
                    duration: 150
                }
            }
        }

        // Kept in sync with the text length one row at a time so existing
        // delegates survive: rebinding an int model would reset the view and
        // replay every character's animation on each keystroke
        ListModel {
            id: charModel
        }

        Connections {
            target: textField
            enabled: input.isPassword
            function onTextChanged() {
                const len = textField.text.length;
                while (charModel.count > len)
                    charModel.remove(charModel.count - 1);
                while (charModel.count < len)
                    charModel.append({ "idx": charModel.count });
            }
        }

        ListView {
            id: charList
            visible: input.isPassword
            anchors.centerIn: parent
            // Slide left when the dots overflow the field, like caelestia
            anchors.horizontalCenterOffset: implicitWidth > middleArea.width
                ? -(implicitWidth - middleArea.width) / 2 : 0
            implicitWidth: count * (input.dotBase + spacing) - (count > 0 ? spacing : 0)
            implicitHeight: input.dotBase
            width: implicitWidth
            height: implicitHeight
            orientation: Qt.Horizontal
            spacing: 1 * Config.generalScale
            interactive: false
            model: charModel

            Behavior on implicitWidth {
                enabled: Config.enableAnimations
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }

            delegate: Item {
                id: char
                width: input.dotBase
                height: input.dotBase

                ListView.onRemove: {
                    initAnim.stop();
                    removeAnim.start();
                }

                Canvas {
                    id: charShape
                    anchors.centerIn: parent
                    width: input.dotBase * 1.5
                    height: width
                    scale: 0
                    opacity: 0

                    // Size of the settled dot relative to the pop-in shape
                    readonly property real settledScale: 0.55

                    // Each character gets its own random shape from the
                    // rounded-star family (scallop, cookie, sunny, burst...),
                    // standing in for caelestia's MaterialShape queue.
                    // morph interpolates it into a plain circle.
                    property real morph: 0
                    readonly property int points: 4 + Math.floor(Math.random() * 5)
                    readonly property real innerRatio: 0.55 + Math.random() * 0.3
                    readonly property real startAngle: Math.random() * Math.PI * 2

                    onMorphChanged: requestPaint()
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = input.contentColor;
                        const cx = width / 2;
                        const cy = height / 2;
                        const R = width / 2;
                        ctx.beginPath();
                        if (morph > 0.99) {
                            ctx.arc(cx, cy, R, 0, Math.PI * 2);
                        } else {
                            // Rounded star: vertices alternate between the outer
                            // and inner radius, joined by quadratic curves through
                            // their midpoints; morph pulls the inner radius out
                            const inner = R * (innerRatio + (1 - innerRatio) * morph);
                            const n = points * 2;
                            const verts = [];
                            for (let i = 0; i < n; i++) {
                                const r = i % 2 === 0 ? R : inner;
                                const a = startAngle + i * Math.PI / points;
                                verts.push([cx + r * Math.cos(a), cy + r * Math.sin(a)]);
                            }
                            const mid = (p, q) => [(p[0] + q[0]) / 2, (p[1] + q[1]) / 2];
                            let m = mid(verts[0], verts[1]);
                            ctx.moveTo(m[0], m[1]);
                            for (let i = 1; i <= n; i++) {
                                const p = verts[i % n];
                                m = mid(p, verts[(i + 1) % n]);
                                ctx.quadraticCurveTo(p[0], p[1], m[0], m[1]);
                            }
                        }
                        ctx.closePath();
                        ctx.fill();
                    }
                    Component.onCompleted: requestPaint()
                }

                SequentialAnimation {
                    id: initAnim
                    running: Config.enableAnimations

                    ParallelAnimation {
                        NumberAnimation {
                            target: charShape
                            property: "opacity"
                            to: 1
                            duration: 150
                        }
                        NumberAnimation {
                            target: charShape
                            property: "scale"
                            to: 1
                            duration: 250
                            easing.type: Easing.OutBack
                        }
                    }
                    PauseAnimation {
                        duration: 180
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: charShape
                            property: "scale"
                            to: charShape.settledScale
                            duration: 250
                            easing.type: Easing.OutBack
                        }
                        NumberAnimation {
                            target: charShape
                            property: "morph"
                            to: 1
                            duration: 250
                        }
                    }
                }

                // No-animation fallback
                Component.onCompleted: {
                    if (!Config.enableAnimations) {
                        charShape.opacity = 1;
                        charShape.scale = charShape.settledScale;
                        charShape.morph = 1;
                    }
                }

                SequentialAnimation {
                    id: removeAnim

                    PropertyAction {
                        target: char
                        property: "ListView.delayRemove"
                        value: true
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: charShape
                            property: "opacity"
                            to: 0
                            duration: 120
                        }
                        NumberAnimation {
                            target: charShape
                            property: "scale"
                            to: 0.4
                            duration: 120
                        }
                    }
                    PropertyAction {
                        target: char
                        property: "ListView.delayRemove"
                        value: false
                    }
                }
            }
        }
    }

    Item {
        id: submitButton
        visible: input.showSubmitButton
        width: visible ? parent.height : 0
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: input.edgePadding

        Rectangle {
            id: submitCircle
            anchors.centerIn: parent
            width: parent.height - input.edgePadding * 2
            height: width
            radius: width / 2
            color: input.text.length > 0
                ? Config.loginButtonActiveBackgroundColor
                : Qt.darker(Config.passwordInputBackgroundColor, 1.07)
            scale: input.text.length === 0 ? 1
                : submitMouse.pressed ? 0.75
                : submitMouse.containsMouse ? 0.95 : 0.85

            Behavior on scale {
                enabled: Config.enableAnimations
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutBack
                }
            }
            Behavior on color {
                enabled: Config.enableAnimations
                ColorAnimation {
                    duration: 200
                }
            }

            Image {
                id: submitIcon
                source: Config.getIcon("arrow-right")
                anchors.centerIn: parent
                width: Math.max(1, Config.passwordInputIconSize * Config.generalScale)
                height: width
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                visible: false
            }

            MultiEffect {
                source: submitIcon
                anchors.fill: submitIcon
                colorization: 1
                colorizationColor: input.text.length > 0
                    ? Config.loginButtonActiveContentColor
                    : input.contentColor
                opacity: input.enabled ? 1.0 : 0.3
                Behavior on colorizationColor {
                    enabled: Config.enableAnimations
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            MouseArea {
                id: submitMouse
                anchors.fill: parent
                enabled: input.enabled
                hoverEnabled: true
                cursorShape: input.text.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (input.text.length > 0)
                        input.accepted();
                }
            }
        }
    }
}
