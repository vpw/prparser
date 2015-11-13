/************************************************************************/
/*									*/ 
/* 	Utility functions for PR parser					*/
/*									*/
/************************************************************************/

#ifndef _PRPARSEUTILS_H_
#define _PRPARSEUTILS_H_
#include <iostream>
#include <vector>
#include <string>
#include <string.h>
#include <stdbool.h>
#include <map>
using namespace std;

#define VS vector<string>
#define SZ size()
#define LN length()
#define PB push_back
#define PoB pop_back

string commonHdr_s("/* -=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= \n* Name        : FSM source file \n* File         : %s \n* Description : Auto generated FSM actions and transitions \n* Author      : PR compiler\n* Date        : %s \n* \n* -=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= \n*/");
string commonFuncHdr_s("/* ---------------------------- ACTION ----------------------------------\n *\n * State : %s\n * Event : %s\n *\n *\n * <pCtx>  : User's context associated to this FSM's instance\n * <pMsg>  : Message associated to the event (NULL if none)\n *\n *\n * Returns : -3        --> FSM is stopped\n *           -4        --> Go to previous state\n *           -5        --> Stay in current state\n *           otherwise --> 0 <= next state value < Number of states\n *\n * ----------------------------------------------------------------------\n */\n");
string commonConnHdr_s("/* -------------------------- LABEL CALL -------------------------------- \n* \n* Label : %s \n* \n* \n* Returns : -3   --> FSM is stopped \n*           -4   --> Go to previous state \n*           -5   --> Stay in current state \n*           >= 0 --> Next state value \n* \n* ---------------------------------------------------------------------- \n*/");
string startHdr_s("/* ------------------------ FSM STARTING POINT --------------------------\n * \n* Called during the FSM's instance initialization \n* \n* \n* \n* <pFsm>  : Object part of this FSM instance \n* <pCtx>  : User's context associated to this FSM's instance \n* \n* Returns : -3        --> FSM stopped or no instructions to execute \n*           otherwise --> 0 <= next state value < Number of states \n* \n* ---------------------------------------------------------------------- \n*/");
VS func;

string funcArgs("P_FSM_USER_DATA_t pCtx, void *pMsg");
string funcCallArgs("(pCtx, pMsg)");
string fsmUdType_s("P_FSM_USER_DATA_t");
string fsmFuncRetType_s("static int");
string fsmStartFuncStart_s("static int fsmStartup(P_FSM_USER_DATA_t pCtx) \n{ \nVAR(int, cr); \n \n/* To avoid compilation warnings */ \nUNUSED_PARAMETER(pCtx); \nUNUSED_PARAMETER(cr); \n \n_HERE_; \n");
string spc_s(" ");
string opPar_s("(");
string clPar_s(")");
string opBrc_s("{");
string clBrc_s("}");
string fsmFuncDefInit_s("VAR(int, cr);\n\n/* To avoid compilation warnings */\nUNUSED_PARAMETER(pCtx);\n");
string fsmFuncMsgInit_s("UNUSED_PARAMETER(pMsg);\n");
string fsmFuncCrInit_s("UNUSED_PARAMETER(cr);\n");
string here_s("_HERE_\n");

string fsmStPref("fsmSt_");
string fsmLblPref("fsmLbl_");
string svcName("");

string currFunc("");				// Name of current function
string currState("");				// Name of the current state

VS states;
VS inputs;
VS labels;

// Functions
void prFSMDataClass();
void prSTT(void);
void prStateLine(void);
void prInputList(void);
void prStateList(void);
void prTail(void);
void handleElseCaseEnd(void);
void decend(void);
void handleElseCaseStart(void);
void handleCaseEnd(void);
void handleDecisionStart(string dec);
void handleCaseStart(string cs);
void handleAltStart(string alt);
void altend(void);
void handleStop(void);
void handleTask(string mq);
void handleJoinStmt(string jn);
void handleNewConn(string in);
void handleCallStmt(int type, string cs);
void handleNewState(string ns);
void handleNewInput(string in);
void handleEndState(void);
void svcInit(string s);
void addState(string st);
bool isState(string st);
void handleNextState(string ns);
void prNextState(string ns);
void addStartFuncStart(void);
void addCommHdr();
void fstart(void);
void fend(void);
bool isInput(string in);
void addInput(string in);

typedef enum callType_e {
	PLAIN=0,
	RET=1,
	PLAIN_COM=2,
	RET_COM=3
} callType;
typedef enum decType_e {
	DEC=0,
	ALT=1
} decType;
typedef struct decLev_st {
	decType dec;
	string decStr;
	bool isStart;
} decLev;
vector<decLev> decParse;
#define MAX_STATES 100
#define MAX_INPUTS 100
VS def(MAX_INPUTS,string(" (P_FSM_TRANS_t)(FSM_TRANS_UNEXPECT)"));
vector<VS> STT(MAX_STATES,def);
map<string, int> stateMap;
map<string, int> inputMap;
int nStates=0;
int nInputs=0;
#endif
