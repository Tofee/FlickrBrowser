import QtQuick 2.9
import QtQuick.Controls 2.2

import "../Core"
import "../Singletons"

BrowserPage {
    id: searchPhotosPage

    pageModelType: "SearchPhotos"

    ListModel {
        id: searchFieldsModel
        ListElement {
            parameter: "tags"
            fieldType: "text"
            fieldContent: []
            title: "tags"
            documentation: "A comma-delimited list of tags. Photos with one or more of the tags listed will be returned. You can exclude results that match a term by prepending it with a - character."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "tag_mode"
            fieldType: "combo"
            fieldContent:      [
                ListElement { text: "any"; optionValue: "any" },
                ListElement { text: "all"; optionValue: "bool" }
            ]
            title: "tag mode"
            documentation: "Either 'any' for an OR combination of tags, or 'all' for an AND combination. Defaults to 'any' if not specified."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "text"
            fieldType: "text"
            fieldContent: []
            title: "text"
            documentation: "A free text search. Photos who's title, description or tags contain the text will be returned. You can exclude results that match a term by prepending it with a - character."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "min_upload_date"
            fieldType: "date"
            fieldContent: []
            title: "min upload date"
            documentation: "Minimum upload date. Photos with an upload date greater than or equal to this value will be returned."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "max_upload_date"
            fieldType: "date"
            fieldContent: []
            title: "max upload date"
            documentation: "Maximum upload date. Photos with an upload date less than or equal to this value will be returned."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "min_taken_date"
            fieldType: "date"
            fieldContent: []
            title: "min taken date"
            documentation: "Minimum taken date. Photos with an taken date greater than or equal to this value will be returned."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "max_taken_date"
            fieldType: "date"
            fieldContent: []
            title: "max taken date"
            documentation: "Maximum taken date. Photos with an taken date less than or equal to this value will be returned."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "license"
            fieldType: "text"
            fieldContent: []
            title: "license"
            documentation: "The license id for photos (for possible values see the flickr.photos.licenses.getInfo method). Multiple licenses may be comma-separated."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "sort"
            fieldType: "combo"
            fieldContent:      [
                ListElement { text: "Date posted (asc)"; optionValue: "date-posted-asc" },
                ListElement { text: "Date posted (desc)"; optionValue: "date-posted-desc" },
                ListElement { text: "Date taken (asc)"; optionValue: "date-taken-asc" },
                ListElement { text: "Date taken (desc)"; optionValue: "date-taken-desc" },
                ListElement { text: "Interestingness (asc)"; optionValue: "Interestingness-asc" },
                ListElement { text: "Interestingness (desc)"; optionValue: "Interestingness-desc" },
                ListElement { text: "Relevance"; optionValue: "relevance" }
            ]
            title: "sort"
            documentation: "The order in which to sort returned photos. Defaults to date-posted-desc (unless you are doing a radial geo query, in which case the default sorting is by ascending distance from the point specified)."
            isSelected: false
            userValue: ""
        }
        ListElement {
            parameter: "privacy_filter"
            fieldType: "combo"
            fieldContent:      [
                ListElement { text: "Public photos"; optionValue: "1" },
                ListElement { text: "Private photos visible to friends"; optionValue: "2" },
                ListElement { text: "Private photos visible to family"; optionValue: "3" },
                ListElement { text: "Private photos visible to friends & family"; optionValue: "4" },
                ListElement { text: "Completely private photos"; optionValue: "5" }
            ]
            title: "privacy filter"
            documentation: "Return photos only matching a certain privacy level."
            isSelected: false
            userValue: ""
        }
    }

    Flickable {
        id: flickableItem

        anchors.fill: parent
        anchors.margins: 10

        contentWidth: width
        contentHeight: columnItem.height
        clip: true
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: columnItem
            x: 0; y: 0
            width: parent.width

            spacing: 4

            Repeater {
                model: searchFieldsModel
                SearchField {
                    width: columnItem.width
                    fieldType: model.fieldType
                    fieldContent: model.fieldContent
                    title: model.title
                    documentation: model.documentation

                    onSelectedChanged: searchFieldsModel.get(index).isSelected = selected;
                    onUserInputChanged: searchFieldsModel.get(index).fieldValue = userInput;
                }
            }

            Button {
                id: searchButton
                text: "Search !"
                height: 50

                onClicked: startSearch();
            }
        }
    }

    function startSearch() {
        var searchParams = [];
        searchParams.push( [ "user_id", "me" ] ); // only search our photos
        searchParams.push( [ "extras", "url_s, url_o" ] );
        var i;
        for( i=0; i<searchFieldsModel.count; ++i ) {
            var fieldItem = searchFieldsModel.get(i);
            if( fieldItem.isSelected ) {
                searchParams.push( [ fieldItem.parameter, fieldItem.fieldValue ] );
            }
        }

        searchPhotosPage.pushNewPage(Qt.resolvedUrl("SearchPhotosResultPage.qml"), "Results", {"searchParams": searchParams});
    }
}
