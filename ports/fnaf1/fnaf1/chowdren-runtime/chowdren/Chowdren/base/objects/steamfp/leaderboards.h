#ifndef _LEADERBOARDS_H
#define _LEADERBOARDS_H

#include "steam/steam_api.h"
#include "steam/isteamuserstats.h"

#define LB_DETAIL_NUM	1
#define LB_ENTRY_MAX	300
#define LB_ENTRY_PAGE	16
#define LB_ENTRY_NUM	LB_ENTRY_PAGE
//amount of pages to load at once
#define LB_ENTRY_LOAD	1
//#define FAKE_LB_LIST
#ifdef FAKE_LB_LIST
#define FAKE_LB_ENTRY	38
#endif
struct SearchBoards {
	CSteamID userid;
	char name[32];
	int ranking;
	int score;
	int details[LB_DETAIL_NUM];
	UGCHandle_t ugchandle;
};
class CSteamLeaderboards
{
public:
	int m_nLeaderboardEntries; // How many entries do we have?
	LeaderboardEntry_t m_leaderboardEntries[LB_ENTRY_MAX]; // The entries
	int m_leaderboardDetails[LB_ENTRY_MAX][LB_DETAIL_NUM];
	int boarderror;
	bool scoresloaded;
	int uploading;
	int scoretoup;
	int detailstoup;
	int modetoup;
	int inftoup;
	int lbcount;
	SearchBoards searchboards[LB_ENTRY_MAX];

	CSteamLeaderboards();
	~CSteamLeaderboards(){};
	
	void FindLeaderboard( const char *pchLeaderboardName );
	void FindTimeLeaderboard( const char *pchLeaderboardName );
	bool UploadScore( int score, int *details );
	bool UploadTimeScore( int score, int *details );
	bool DownloadScores( int mode, int index );
	void ResetLBStruct();
#ifdef FAKE_LB_LIST
	void FakeLBStruct();
#endif

	void OnFindLeaderboard( LeaderboardFindResult_t *pResult, bool bIOFailure);
	CCallResult< CSteamLeaderboards, LeaderboardFindResult_t > m_callResultFindLeaderboard;
	void OnUploadScore( LeaderboardScoreUploaded_t *pResult, bool bIOFailure);
	CCallResult< CSteamLeaderboards, LeaderboardScoreUploaded_t > m_callResultUploadScore;
	void OnFindTimeLeaderboard( LeaderboardFindResult_t *pResult, bool bIOFailure);
	CCallResult< CSteamLeaderboards, LeaderboardFindResult_t > m_callResultFindTimeLeaderboard;
	void OnUploadTimeScore( LeaderboardScoreUploaded_t *pResult, bool bIOFailure);
	CCallResult< CSteamLeaderboards, LeaderboardScoreUploaded_t > m_callResultUploadTimeScore;
	void OnDownloadScore( LeaderboardScoresDownloaded_t *pResult, bool bIOFailure);
	CCallResult< CSteamLeaderboards, LeaderboardScoresDownloaded_t > m_callResultDownloadScore;

	SteamLeaderboard_t m_CrystalLeaderboard; // Handle to leaderboard
	SteamLeaderboard_t m_TimeLeaderboard; // Handle to leaderboard
};
#endif
