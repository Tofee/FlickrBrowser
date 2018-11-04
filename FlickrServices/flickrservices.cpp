#include <QFileInfo>
#include <QVariant>
#include <QString>
#include <QTextStream>
#include <QFile>

#include <exiv2/exiv2.hpp>

#include "flickrservices.h"

FlickrServices::FlickrServices(QObject *parent):
    QObject(parent)
{
}

FlickrServices::~FlickrServices()
{
}

bool FlickrServices::writeToFile(const QString &filePath, const QString &str)
{
    QFile file(filePath);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << str << "\n";

    file.close();

    return true;
}

/*!
 * \qmlmethod variant FlickrServices::getFileProperty(string filePath, string prop)
 * The function retrieves the 'prop' property of the file 'filePath'.
 * Valid properties are: fileName, fileExtension
 */
QVariant FlickrServices::getFileProperty(const QString &filePath, const QString &prop)
{
    QVariant lPropertyValue;

    if( prop == "fileName" ) {
        QFileInfo lFileInfo(filePath);
        lPropertyValue = lFileInfo.fileName();
    }
    else if( prop == "fileExtension" ) {
        QFileInfo lFileInfo(filePath);
        lPropertyValue = lFileInfo.suffix();
    }

    return lPropertyValue;
}

/*!
 * \qmlmethod variant FlickrServices::getExifProperty(string filePath, string prop)
 * The function retrieves the 'prop' Exif property of the image 'filePath'.
 * Valid properties are: description, tagList
 */
QVariant FlickrServices::getExifProperty(const QString &filePath, const QString &prop)
{
    QVariant lPropertyValue;

    if( prop == "description" )
        lPropertyValue = QString();
    else if( prop == "width" || prop == "height" )
        lPropertyValue = (int)0;
    else if( prop == "tagList" )
        lPropertyValue = QStringList();

    QFileInfo lFileInfo(filePath);
    if( !lFileInfo.isFile() ) return lPropertyValue;

    std::string stdPath=filePath.toStdString();
    Exiv2::Image::AutoPtr imageExiv2 = Exiv2::ImageFactory::open(stdPath);
    if( imageExiv2->good() ) {
        imageExiv2->readMetadata();
        Exiv2::ExifData &exifData = imageExiv2->exifData();
        Exiv2::IptcData &iptcData = imageExiv2->iptcData();

        if( prop == "description" ) {
            lPropertyValue = QString();

            Exiv2::ExifKey exifKey("Exif.Image.ImageDescription");
            Exiv2::ExifData::const_iterator posDescription = exifData.findKey(exifKey);
            if( posDescription != exifData.end() )
                lPropertyValue = QString::fromStdString(posDescription->toString());
        }
        else if( prop == "width" ) {
            lPropertyValue = imageExiv2->pixelWidth();
        }
        else if( prop == "height" ) {
            lPropertyValue = imageExiv2->pixelHeight();
        }
        else if( prop == "tagList" ) {
            lPropertyValue = QStringList();

            Exiv2::IptcKey iptcKey("Iptc.Application2.Keywords");
            Exiv2::IptcData::const_iterator tagsDescription = iptcData.findKey(iptcKey);
            QStringList lKeyworksList;
            while( tagsDescription != iptcData.end() ) {
                lKeyworksList += QString::fromStdString(tagsDescription->toString());
                ++tagsDescription;
            }

            lPropertyValue = lKeyworksList;
        }
    }

    return lPropertyValue;
}

