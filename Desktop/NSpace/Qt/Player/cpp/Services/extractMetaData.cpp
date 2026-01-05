#include "extractMetaData.h"

// TagLib 核心头文件
#include <taglib/mpegfile.h>
#include <taglib/id3v2tag.h>
#include <taglib/attachedpictureframe.h>
#include <taglib/flacfile.h>
#include <taglib/fileref.h>
#include <taglib/tag.h>
#include <taglib/audioproperties.h>

#include <QBuffer>
#include <QImage>

QVariantMap MusicMetadataHelper::extractMetadata(const QString &filePath) {
    QVariantMap metadata;
    metadata["success"] = false;

    // 1. 路径转换 (2026/01/06 推荐：Windows 下用 utf16 避免中文乱码)
#ifdef Q_OS_WIN
    std::wstring path = reinterpret_cast<const wchar_t*>(filePath.utf16());
#else
    std::string path = filePath.toLocal8Bit().data();
#endif

    TagLib::FileRef f(path.c_str());

    if (!f.isNull()) {
        // --- 2. 文本标签 (Tag) 提取 ---
        if (f.tag()) {
            TagLib::Tag *tag = f.tag();
            // 核心元数据
            metadata["title"]   = QString::fromUtf8(tag->title().toCString(true));
            metadata["artist"]  = QString::fromUtf8(tag->artist().toCString(true));
            metadata["album"]   = QString::fromUtf8(tag->album().toCString(true));

            // 备用/扩展元数据
            metadata["year"]    = tag->year();
            metadata["track"]   = tag->track();
            metadata["genre"]   = QString::fromUtf8(tag->genre().toCString(true));
            metadata["comment"] = QString::fromUtf8(tag->comment().toCString(true));
        }

        // --- 3. 音频流属性提取 ---
        if (f.audioProperties()) {
            TagLib::AudioProperties *prop = f.audioProperties();
            metadata["duration"]   = prop->lengthInSeconds(); // 时长(秒)
            metadata["bitrate"]    = prop->bitrate();        // 比特率(kbps)
            metadata["sampleRate"] = prop->sampleRate();     // 采样率(Hz)
            metadata["channels"]   = prop->channels();       // 声道数
        }

        // --- 4. 封面提取并转 Base64 ---
        QString base64Cover = "";

        // 逻辑：优先尝试 MP3 (ID3v2 APIC 帧)
        TagLib::MPEG::File mpegFile(path.c_str());
        if (mpegFile.isValid() && mpegFile.ID3v2Tag()) {
            auto frameList = mpegFile.ID3v2Tag()->frameList("APIC");
            if (!frameList.isEmpty()) {
                auto *picFrame = static_cast<TagLib::ID3v2::AttachedPictureFrame *>(frameList.front());
                base64Cover = "data:image/jpeg;base64," +
                              QByteArray(picFrame->picture().data(), picFrame->picture().size()).toBase64();
            }
        }

        // 如果不是 MP3 或没封面，尝试 FLAC
        if (base64Cover.isEmpty()) {
            TagLib::FLAC::File flacFile(path.c_str());
            if (flacFile.isValid() && !flacFile.pictureList().isEmpty()) {
                auto pic = flacFile.pictureList().front();
                base64Cover = "data:image/png;base64," +
                              QByteArray(pic->data().data(), pic->data().size()).toBase64();
            }
        }

        metadata["cover"] = base64Cover;
        metadata["success"] = true;
    }

    return metadata;
}
