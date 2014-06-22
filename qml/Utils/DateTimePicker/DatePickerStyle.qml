import QtQuick 2.0

/*
Copyright (c) 2011-2012, Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of the vsorokin nor the names of its contributors may be used to endorse or
promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


This file is a part of Datepicker component.
*/

QtObject {
    id: style

    property string backgroundImage: Qt.resolvedUrl("meegotouch-calendar-monthgrid-background-landscape.png");
    property string currentDayImage: Qt.resolvedUrl("meegotouch-monthgrid-daycell-current-day-landscape.png");
    property string selectedDayImage: Qt.resolvedUrl("meegotouch-monthgrid-daycell-selected-day-landscape.png");
    property string currentSelectedDayImage: Qt.resolvedUrl("meegotouch-monthgrid-daycell-selected-day-current-landscape.png");

    property string leftArrowImage: Qt.resolvedUrl("meegotouch-calendar-monthgrid-previousbutton.png");
    property string leftArrowPressedImage: Qt.resolvedUrl("meegotouch-calendar-monthgrid-previousbutton-pressed.png");
    property string rightArrowImage: Qt.resolvedUrl("meegotouch-calendar-monthgrid-nextbutton.png");
    property string rightArrowPressedImage: Qt.resolvedUrl("meegotouch-calendar-monthgrid-nextbutton-pressed.png");


    property string eventImage: Qt.resolvedUrl("meegotouch-monthgrid-daycell-regular-day-eventindicator.png");
    property string weekEndEventImage: Qt.resolvedUrl("meegotouch-monthgrid-daycell-regular-weekend-day-eventindicator.png");
    property string currentDayEventImage: Qt.resolvedUrl("meegotouch-monthgrid-daycell-current-day-eventindicator.png");
    property string selectedDayEventImage: Qt.resolvedUrl("meegotouch-monthgrid-daycell-selected-day-eventindicator.png");
    property string otherMonthEventImage: Qt.resolvedUrl("meegotouch-monthgrid-daycell-othermonth-day-eventindicator.png");

    property color weekEndColor: "#EF5500"
    property color weekDayColor: "#8C8C8C"
    property color otherMonthDayColor: "#8C8C8C"
    property color dayColor: "#000000"
    property color monthColor: "#000000"
    property color currentDayColor: "#EF5500"
    property color selectedDayColor: "#FFFFFF"

    property int monthFontSize: 16 // 32
    property int dayNameFontSize: 9 // 18
    property int dayFontSize: 13 // 26
}
