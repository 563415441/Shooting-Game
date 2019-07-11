#include "gamedata.h"
#include <QFile>
#include <QJsonDocument>

GameData::GameData()
{

}

int GameData::score() const
{
    return m_score;
}

void GameData::setScore(const int score)
{
    m_score = score;

}

int GameData::level() const
{
    return  m_level;
}
void GameData::setLevel(const int level)
{
    m_level = level;

}
void GameData::read(const QJsonObject &json)
{
    if(json.contains("score") && json["score"].isDouble())
     m_score = json["score"].toInt();
    if(json.contains("level") && json["level"].isDouble())
     m_score = json["level"].toInt();
}

void GameData::write(QJsonObject  &json)
{
    json["score"] = m_score;
    json["level"] = m_level;

}
bool GameData::load()
{
    //inport json
    QFile loadFile(QStringLiteral("gamedata.json"));
    if(!loadFile.open(QIODevice::ReadOnly)){
        qWarning("can not open file");
        return false;
    }
    QByteArray gamedata = loadFile.readAll();
    QJsonDocument loadDoc(QJsonDocument::fromJson(gamedata));
    QJsonObject json(loadDoc.object());
    read(json);
    return true;
}
bool GameData::save()
{
    QFile saveFile(QStringLiteral("gamedata.json"));
    if(!saveFile.open(QIODevice::WriteOnly)){
        qWarning("can not open file");
        return false;
    }
    QJsonObject data;
    write(data);
    QJsonDocument saveDoc(data);
    saveFile.write(saveDoc.toJson());
    return true;
}
