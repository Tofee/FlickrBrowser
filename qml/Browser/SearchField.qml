import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import "../Utils/DateTimePicker"

RowLayout {
    property string title
    property alias selected: activeCheckBox.checked
    property alias userInput:searchFieldLoader.userInput

    property string fieldType: "text"
    property variant fieldContent
    property string documentation

    CheckBox {
        id: activeCheckBox
        Layout.alignment: Qt.AlignTop
        text: title

        style: CheckBoxStyle {
                    label: Text {
                        text: control.text
                        color: selected ? "white" : "grey"
                        font.bold: selected
                    }
               }
    }

    Column {
        Layout.fillWidth: true

        Loader {
            id: searchFieldLoader
            width: parent.width

            property string userInput
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            text: documentation
            color: "white"
            font.italic: true
        }
    }
    Component.onCompleted: {
        if( fieldType === "text" )
            searchFieldLoader.sourceComponent = textFieldComp;
        else if( fieldType === "combo" )
            searchFieldLoader.sourceComponent = comboFieldComp;
        else if( fieldType === "date" )
            searchFieldLoader.sourceComponent = dateFieldComp;
    }

    // search field components
    Component {
        id: textFieldComp
        TextField {
            id: textField
            enabled: selected
            placeholderText: "<empty>"
            onTextChanged: userInput = text;
        }
    }
    Component {
        id: comboFieldComp
        ComboBox {
            id: textField
            enabled: selected
            model: fieldContent
            textRole: "text"
            onCurrentTextChanged: userInput = model.get(currentIndex).optionValue;
        }
    }
    Component {
        id: dateFieldComp
        Column {
            id: dateTimeColumn
            enabled: selected

            property date fieldDate: new Date();
            Button {
                id: dateTimeCheckButton
                height: 30
                width: 170 + 5 + 160
                checkable: true
                text: dateTimeColumn.fieldDate.toLocaleString(Qt.locale(), "'Date :' ddd yyyy-MM-dd 'Time :' H:mm");
            }
            Row {
                spacing: 5
                DatePicker {
                    id: datePicker
                    visible: dateTimeCheckButton.checked
                    height: 160
                    width: 170
                    property date userSelectedDate;
                    onSelectedDateChanged: {
                        userSelectedDate = selectedDate;
                        updateDateTime();
                    }
                }
                TimePicker {
                    id: timePicker
                    visible: dateTimeCheckButton.checked
                    height: 160
                    width: 160
                    onHoursChanged: updateDateTime();
                    onMinutesChanged: updateDateTime();
                }
            }
            Component.onCompleted: {
                var currentDateTime = new Date();
                timePicker.hours = currentDateTime.getHours();
                timePicker.minutes = currentDateTime.getMinutes();
                fieldDate = currentDateTime;
            }
            function updateDateTime() {
                var selectedDate = datePicker.userSelectedDate;
                dateTimeColumn.fieldDate = new Date(selectedDate.getFullYear(),
                                                    selectedDate.getMonth(),
                                                    selectedDate.getDate(),
                                                    timePicker.hours,
                                                    timePicker.minutes);
                userInput = Math.round(dateTimeColumn.fieldDate.getTime() / 1000).toString(); // convert to Unix timestamp
            }
        }
    }
}

