-- Create Users table
CREATE TABLE Users (
    UserID INTEGER PRIMARY KEY AUTOINCREMENT,
    Username TEXT NOT NULL UNIQUE,
    Email TEXT NOT NULL UNIQUE,
    Password TEXT NOT NULL
);

-- Create Music table
CREATE TABLE Music (
    MusicID INTEGER PRIMARY KEY AUTOINCREMENT,
    Title TEXT NOT NULL,
    Artist TEXT NOT NULL,
    Genre TEXT,
    ReleaseDate DATE,
    Album TEXT
);

-- Create Emotions table
CREATE TABLE Emotions (
    EmotionID INTEGER PRIMARY KEY AUTOINCREMENT,
    EmotionName TEXT NOT NULL UNIQUE
);

-- Create Recommendations table
CREATE TABLE Recommendations (
    RecommendationID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    MusicID INTEGER,
    EmotionID INTEGER,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (MusicID) REFERENCES Music(MusicID),
    FOREIGN KEY (EmotionID) REFERENCES Emotions(EmotionID)
);

-- Create PlaybackHistory table
CREATE TABLE PlaybackHistory (
    PlaybackID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    MusicID INTEGER,
    EmotionID INTEGER,
    PlayTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (MusicID) REFERENCES Music(MusicID),
    FOREIGN KEY (EmotionID) REFERENCES Emotions(EmotionID)
);

-- Create UserPreferences table
CREATE TABLE UserPreferences (
    PreferenceID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    PreferredEmotionID INTEGER,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (PreferredEmotionID) REFERENCES Emotions(EmotionID)
);

-- Create Index on Users table (Email)
CREATE INDEX idx_Users_Email ON Users(Email);

-- Create Trigger to update Music.LastPlayed
CREATE TRIGGER UpdateLastPlayed
AFTER INSERT ON PlaybackHistory
BEGIN
    UPDATE Music
    SET LastPlayed = (SELECT PlayTime FROM PlaybackHistory WHERE MusicID = NEW.MusicID ORDER BY PlayTime DESC LIMIT 1)
    WHERE MusicID = NEW.MusicID;
END;

-- Create View for User Preferences vs. Recommendations
CREATE VIEW UserPreferredRecommendations AS
SELECT DISTINCT u.Username, m.Title, m.Artist, e.EmotionName
FROM UserPreferences up
JOIN Recommendations r ON up.UserID = r.UserID
JOIN Music m ON r.MusicID = m.MusicID
JOIN Emotions e ON r.EmotionID = e.EmotionID
WHERE e.EmotionID = up.PreferredEmotionID;

-- Example of Complex SELECT Query
SELECT u.Username, m.Title, m.Artist, ph.PlayTime
FROM Users u
JOIN PlaybackHistory ph ON u.UserID = ph.UserID
JOIN Music m ON ph.MusicID = m.MusicID
JOIN Emotions e ON ph.EmotionID = e.EmotionID
WHERE e.EmotionName = 'Happy';

-- Example of Subquery for Top Played Songs
SELECT m.Title, m.Artist, song_count
FROM Music m
JOIN (
    SELECT MusicID, COUNT(*) as song_count
    FROM PlaybackHistory
    GROUP BY MusicID
    ORDER BY song_count DESC
    LIMIT 3
) top_songs ON m.MusicID = top_songs.MusicID;