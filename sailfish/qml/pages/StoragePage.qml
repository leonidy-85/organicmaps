import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "notices.js" as Toast

Page {
    allowedOrientations: Orientation.All
    // The maps move on the next start.
    backNavigation: !mapsStorage.movePending
    showNavigationIndicator: backNavigation
    onStatusChanged: if (status === PageStatus.Activating) mapsStorage.refresh()

    SilicaListView {
        id: listView
        anchors.fill: parent
        visible: !mapsStorage.movePending
        model: mapsStorage.locations

        header: Column {
            width: listView.width

            PageHeader {
                title: appInfo.localized("maps_storage")
            }
            PageLabel {
                text: appInfo.localized("maps_storage_summary")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                bottomPadding: Theme.paddingLarge
            }
            DetailItem {
                label: appInfo.localized("maps_storage_downloaded")
                value: mapsStorage.downloadedSize
            }
        }

        delegate: ListItem {
            id: item
            contentHeight: Theme.itemSizeMedium
            highlighted: down || modelData.current
            onClicked: {
                if (modelData.current)
                    return
                var path = modelData.path
                remorseAction(appInfo.localized("move_maps"), function() {
                    if (!mapsStorage.moveTo(path))
                        Toast.showLong(appInfo.localized("move_maps_error"))
                })
            }

            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    width: parent.width
                    text: modelData.name
                    highlighted: item.highlighted
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    width: parent.width
                    text: modelData.details
                    font.pixelSize: Theme.fontSizeSmall
                    color: item.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
            }
        }

        footer: Column {
            width: listView.width
            // A gap between the storage locations above and the folder choice below them.
            topPadding: Theme.paddingLarge
            bottomPadding: Theme.paddingLarge

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: appInfo.localized("maps_storage_folder")
                onClicked: pageStack.push(folderPicker)
            }
        }

        VerticalScrollDecorator {}
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 2 * Theme.horizontalPageMargin
        visible: mapsStorage.movePending
        spacing: Theme.paddingLarge

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: appInfo.localized("maps_storage_restart")
            wrapMode: Text.Wrap
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: appInfo.localized("close")
            onClicked: Qt.quit()
        }
    }

    Component {
        id: folderPicker

        FolderPickerPage {
            dialogTitle: appInfo.localized("maps_storage_folder")
            onSelectedPathChanged: {
                if (!mapsStorage.moveTo(selectedPath))
                    Toast.showLong(appInfo.localized("move_maps_error"))
            }
        }
    }
}
