#include "leaderboards.h"
#include "steam/steam_api.h"
#include "steam/isteamuserstats.h"

//Constructor
//What it does - The constructor initializes a number of members. 
CSteamLeaderboards::CSteamLeaderboards():
 m_nLeaderboardEntries( 0 ),
 boarderror(0),
 scoresloaded(false),
 uploading(0),
 scoretoup(0),
 detailstoup(0),
 modetoup(0),
 inftoup(0),
 lbcount(0),
 m_CrystalLeaderboard( NULL ),
 m_TimeLeaderboard( NULL )
{
}

//FindLeaderboard()
//Parameters - The string identifier of the leaderboard that you want to find (ie. "Feet Traveled")
//What it does - This method wraps a call to SteamUserStats()->FindLeaderboard() that is an asynchronous call to steam requesting a handle to the given leaderboard. This call needs to be made before you can retrieve or set leaderboard entries. This method also sets up the call return method to use.
void CSteamLeaderboards::FindLeaderboard( const char *pchLeaderboardName )
{
	uploading=1;
	boarderror=0;
	scoresloaded=false;
	m_CrystalLeaderboard = NULL;
	m_nLeaderboardEntries = 0;
	int i,j;
	for(i=0;i<LB_ENTRY_NUM;i++){
		m_leaderboardEntries[i].m_nScore = 0;
		for(j=0;j<LB_DETAIL_NUM;j++)
			m_leaderboardDetails[i][j] = 0;
	}

	SteamAPICall_t hSteamAPICall = SteamUserStats()->FindLeaderboard(pchLeaderboardName);
	m_callResultFindLeaderboard.Set(hSteamAPICall, this, &CSteamLeaderboards::OnFindLeaderboard);
}

void CSteamLeaderboards::FindTimeLeaderboard( const char *pchLeaderboardName )
{
	uploading=1;
	boarderror=0;
	scoresloaded=false;
	m_TimeLeaderboard = NULL;
	m_nLeaderboardEntries = 0;
	int i,j;
	for(i=0;i<LB_ENTRY_NUM;i++){
		m_leaderboardEntries[i].m_nScore = 0;
		for(j=0;j<LB_DETAIL_NUM;j++)
			m_leaderboardDetails[i][j] = 0;
	}

	SteamAPICall_t hSteamAPICall = SteamUserStats()->FindLeaderboard(pchLeaderboardName);
	m_callResultFindTimeLeaderboard.Set(hSteamAPICall, this, &CSteamLeaderboards::OnFindTimeLeaderboard);
}

//OnFindLeaderboard()
//What it does - This method is a callback that is called anytime we attempt to find a leaderboard on Steam. If the requested leaderboard was found then we set that leaderboard handle as our current leaderboard.
void CSteamLeaderboards::OnFindLeaderboard( LeaderboardFindResult_t *pCallback,	bool bIOFailure )
{
	// see if we encountered an error during the call
	if ( !pCallback->m_bLeaderboardFound || bIOFailure )
	{
		boarderror=1;
		return;
	}

	m_CrystalLeaderboard = pCallback->m_hSteamLeaderboard;
}

void CSteamLeaderboards::OnFindTimeLeaderboard( LeaderboardFindResult_t *pCallback,	bool bIOFailure )
{
	// see if we encountered an error during the call
	if ( !pCallback->m_bLeaderboardFound || bIOFailure )
	{
		boarderror=1;
		return;
	}

	m_TimeLeaderboard = pCallback->m_hSteamLeaderboard;
}

//UploadScore()
//Parameters - an int32 representing the value to store in the current leaderboard.
//Returns - false if a leaderboard has not been selected yet, otherwise it returns true.
//What it does - This method wraps a call to SteamUserStats()->UploadLeaderboardScore() that is an asynchronous call to steam uploading the score of the current user to the currently selected leaderboard. This method also sets up the call return method to use. This call needs to be made after you have selected a leaderboard using FindLeaderboard().
bool CSteamLeaderboards::UploadScore( int score, int *details )
{
	if(boarderror==2)
		boarderror=0;
	uploading=2;
	if (!m_CrystalLeaderboard)
		return false;

#ifndef NOSCOREUPLOAD
	SteamAPICall_t hSteamAPICall = 
	 SteamUserStats()->UploadLeaderboardScore( m_CrystalLeaderboard, k_ELeaderboardUploadScoreMethodKeepBest, score, details, LB_DETAIL_NUM );

	m_callResultUploadScore.Set(hSteamAPICall, this, &CSteamLeaderboards::OnUploadScore);
#else
	AllowUGCNow=false;
	uploading=4;
#endif

	return true;
}

bool CSteamLeaderboards::UploadTimeScore( int score, int *details )
{
	if(boarderror==2)
		boarderror=0;
	uploading=2;
	if (!m_TimeLeaderboard)
		return false;

#ifndef NOSCOREUPLOAD
	SteamAPICall_t hSteamAPICall = 
	 SteamUserStats()->UploadLeaderboardScore( m_TimeLeaderboard, k_ELeaderboardUploadScoreMethodKeepBest, score, details, LB_DETAIL_NUM );

	m_callResultUploadTimeScore.Set(hSteamAPICall, this, &CSteamLeaderboards::OnUploadTimeScore);
#else
	AllowUGCNow=false;
	uploading=4;
#endif

	return true;
}

//OnUploadScore()
//What it does - This method is a callback that is called anytime we attempt to upload a score to a leaderboard on Steam.
void CSteamLeaderboards::OnUploadScore(LeaderboardScoreUploaded_t *pCallback, bool bIOFailure)
{
	if ( !pCallback->m_bSuccess || bIOFailure )
	{
		uploading=3;
		boarderror=2;
	} else {
		uploading=4;
		if(pCallback->m_bScoreChanged){
		} else {
			uploading=3;
		}
	}
}

void CSteamLeaderboards::OnUploadTimeScore(LeaderboardScoreUploaded_t *pCallback, bool bIOFailure)
{
	if ( !pCallback->m_bSuccess || bIOFailure )
	{
		uploading=3;
		boarderror=2;
	} else {
		uploading=4;
		if(pCallback->m_bScoreChanged){
		} else {
			uploading=3;
		}
	}
}

//DownloadScores()
//Returns - false if a leaderboard has not been selected yet, otherwise it returns true.
//What it does - This method wraps a call to SteamUserStats()->DownloadLeaderboardEntries() that is an asynchronous call to steam downloading a set of entries from the currently selected leaderboard. In this case we are downloading ten entries; four before the current user, the current user and five after the current user. This call can be altered to return any number of entries from any place in the leaderboard. This method also sets up the call return method to use. This call needs to be made after you have selected a leaderboard using FindLeaderboard().
bool CSteamLeaderboards::DownloadScores( int mode, int index )
{
	if(boarderror==3)
		boarderror=0;
	scoresloaded=false;
	if (!m_CrystalLeaderboard)
		return false;

	SteamAPICall_t hSteamAPICall = NULL;
	// load the specified leaderboard data around the current user
	if(mode==(int)k_ELeaderboardDataRequestGlobalAroundUser)
		hSteamAPICall = SteamUserStats()->DownloadLeaderboardEntries( m_CrystalLeaderboard, (ELeaderboardDataRequest)mode, 0, 0);
	else
		hSteamAPICall = SteamUserStats()->DownloadLeaderboardEntries( m_CrystalLeaderboard, (ELeaderboardDataRequest)mode, index, index+(LB_ENTRY_PAGE*LB_ENTRY_LOAD));
	m_callResultDownloadScore.Set(hSteamAPICall, this, &CSteamLeaderboards::OnDownloadScore);

	return true;
}

//OnDownloadScore()
//What it does - This method is a callback that is called anytime we attempt to download entries from a leaderboard on Steam. If the data was successfully downloaded then we copy the data into our array of entries. The number of entries downloaded is stored in m_nLeaderboardEntries.
void CSteamLeaderboards::OnDownloadScore(LeaderboardScoresDownloaded_t *pCallback, bool bIOFailure)
{
	if (pCallback->m_hSteamLeaderboard != m_CrystalLeaderboard){
		return;
	}
	else if (!bIOFailure)
	{
		m_nLeaderboardEntries = pCallback->m_cEntryCount;
		boards.lbcount=SteamUserStats()->GetLeaderboardEntryCount(m_CrystalLeaderboard);

		ResetLBStruct();
		for (int index = 0; index < m_nLeaderboardEntries; index++)
   		{
			SteamUserStats()->GetDownloadedLeaderboardEntry(pCallback->m_hSteamLeaderboardEntries,index,&m_leaderboardEntries[index],m_leaderboardDetails[index],LB_DETAIL_NUM);
			int j;
			searchboards[index].userid = m_leaderboardEntries[index].m_steamIDUser;
			searchboards[index].ranking = m_leaderboardEntries[index].m_nGlobalRank;
			searchboards[index].score = m_leaderboardEntries[index].m_nScore;
			searchboards[index].ugchandle = m_leaderboardEntries[index].m_hUGC;
			for(j=0;j<LB_DETAIL_NUM;j++)
				searchboards[index].details[j] = m_leaderboardDetails[index][j];
		}
#ifdef FAKE_LB_LIST
		m_nLeaderboardEntries = FAKE_LB_ENTRY;
		boards.lbcount = FAKE_LB_ENTRY;
#endif
		scoresloaded=true;
	} else {
		boarderror=3;
	}
#ifdef FAKE_LB_LIST
	FakeLBStruct();
#endif
}

void CSteamLeaderboards::ResetLBStruct()
{
	int i,j;
	for (i=0;i<LB_ENTRY_MAX;i++){
		searchboards[i].userid.CreateBlankAnonLogon(k_EUniverseInvalid);
		_snprintf(searchboards[i].name,32,"UNKNOWN");
		searchboards[i].ranking = 0;
		searchboards[i].score = 0;
		searchboards[i].ugchandle = k_UGCHandleInvalid;
		for(j=0;j<LB_DETAIL_NUM;j++)
			searchboards[i].details[j] = 0;
	}
	return;
}

#ifdef FAKE_LB_LIST
void CSteamLeaderboards::FakeLBStruct()
{
	int i=0;
	ResetLBStruct();
	for(i=i;i<FAKE_LB_ENTRY;i++){
		searchboards[i].userid.CreateBlankAnonLogon(k_EUniverseInvalid);
		searchboards[i].ranking = i;
		searchboards[i].score = 1;
		searchboards[i].ugchandle = k_UGCHandleInvalid;
		searchboards[i].details[0] = 1;
		searchboards[i].details[1] = 1;
		searchboards[i].details[2] = 1;
		searchboards[i].details[3] = 1;
		searchboards[i].details[4] = 1;
		searchboards[i].details[5] = 1;
		searchboards[i].details[6] = 1;
		searchboards[i].details[7] = 1;
		searchboards[i].details[8] = 1;
		searchboards[i].name[0]=65+(rand()%26);
		searchboards[i].name[1]=65+(rand()%26);
		searchboards[i].name[2]=65+(rand()%26);
		searchboards[i].name[3]=65+(rand()%26);
		searchboards[i].name[4]=65+(rand()%26);
		searchboards[i].name[5]=65+(rand()%26);
		searchboards[i].name[6]=65+(rand()%26);
		searchboards[i].name[7]=65+(rand()%26);
		searchboards[i].name[8]=65+(rand()%26);
		searchboards[i].name[9]=65+(rand()%26);
		searchboards[i].name[10]=65+(rand()%26);
		searchboards[i].name[11]=65+(rand()%26);
		searchboards[i].name[12]=65+(rand()%26);
		searchboards[i].name[13]=65+(rand()%26);
		searchboards[i].name[14]=65+(rand()%26);
		searchboards[i].name[15]=65+(rand()%26);
		searchboards[i].name[16]=0;
	}
	return;
}
#endif
