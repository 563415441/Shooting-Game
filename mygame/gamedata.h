#ifndef GAMEDATA_H
#define GAMEDATA_H

#include <QObject>
#include <QJsonObject>

class GameData :public QObject
{
   Q_OBJECT
    Q_PROPERTY(int score READ score WRITE setScore NOTIFY scoreChanged)
    Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged)
public:
    GameData();
    int score()const;
    void setScore(const int score);
    int level()const;
    void setLevel(const int level);
    Q_INVOKABLE bool load();
    Q_INVOKABLE bool save();
    void read(const QJsonObject &json);
    void write(QJsonObject &json);
signals:
    void scoreChanged();
    void levelChanged();
private:
    int m_score;
    int m_level;
};
#endif // GAMEDATA_H
