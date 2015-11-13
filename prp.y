%{
#include <iostream>
#include <fstream>
using namespace std;
#include <stdio.h>
//#include <sys/time.h>

extern "C" {
int yyparse(void);
int yylex(void);
int yywrap() {
	return 1;
}
}

//#include "prParseUtils.h"
#include "prExt.h"

#define DBG(X) X

%}

%union {
	char str[8192];
	int intval;
}

%token <str> COMMENT
%token <str> VAR 
%token <str> MULTIQUOTE
%token <str> '('
%token <str> ')'
%token <str> ','
%token CASE FUNCTIONCALL INPUT
%token SERVICE ENDSERVICE START STATE ENDSTATE CALL ALTERNATIVE ENDALTERNATIVE TASK JOIN DECISION ENDDECISION CONNECTION ENDCONNECTION STOP NEXTSTATE ELSE

%type <str> args
%type <str> function
%type <str> altstart
%type <str> mqs
%%

file: service
;
service: servicestart validblocks ENDSERVICE ';' {
		prTail();
}
	| servicestart startblk validblocks ENDSERVICE ';' {
		prTail();
}
;
validblocks: states
	| connections
	| validblocks state
	| validblocks connection
;
startblk: starttoken ';' validstmts nextstatestmt { 
		fend(); 
}
	| starttoken ';' nextstatestmt	{
		fend();
}
;
starttoken: START { 

		addStartFuncStart();
		fstart();
}
;
servicestart: SERVICE VAR ';' 	{ 

		svcInit(string($2));
		addCommHdr();
}
;
states: state
	| states state
;
state: statestart inputs ENDSTATE ';' {
		handleEndState();
}
	| statestart commentstmt inputs ENDSTATE ';'
;
connections: connection
	| connections connection
;
connection: connectionstart validstmts ENDCONNECTION ';' {
		fend();
}
;
connectionstart: CONNECTION VAR ':' {
		handleNewConn(string($2));
}
;
statestart: STATE VAR ';' {
		handleNewState(string($2));
}
	| STATE VAR commentstmt	{
		handleNewState(string($2));
		// Comment for state is skipped - TBC where to use.
}
;
inputs: input
	| inputs input
;
input: inputstart validstmts {
		fend();
}
;
inputstart: INPUT VAR ';' { 
		handleNewInput(string($2));
}
	| INPUT VAR commentstmt { 
		handleNewInput(string($2));
		// Comment for state is skipped - TBC where to use.
}
;
validstmts: validstmt
	| validstmts validstmt
;
validstmt: callstmt
	| alternativestmt
	| nextstatestmt
	| commentstmt
	| decisionstmt
	| joinstmt
	| taskstmt
	| stopstmt
;
stopstmt: STOP ';' {
		handleStop();
}
;
taskstmt: TASK mqs ';' {
		handleTask(string($2));
}
	| TASK mqs commentstmt {
		handleTask(string($2));
}
;
joinstmt: JOIN VAR ';' {
		handleJoinStmt(string($2));
}
	| JOIN VAR commentstmt {
		handleJoinStmt(string($2));
		// Comment for Join is skipped - TBC where to use.
}
;
decisionstmt: decisionstart cases elsecase ENDDECISION ';' { 
		decend();
}
	| decisionstart commentstmt cases elsecase ENDDECISION ';' { 
		decend();
}
;
decisionstart: DECISION mqs {
		handleDecisionStart(string($2));
}
	| DECISION mqs ';' {
		handleDecisionStart(string($2));
}
;
commentstmt: COMMENT mqs ';'
;
nextstatestmt: NEXTSTATE VAR ';' { 
		handleNextState(string($2).c_str());
}
	| NEXTSTATE VAR commentstmt { 
		handleNextState(string($2).c_str());
}
	| NEXTSTATE '-' ';' { 
		handleNextState(string("-").c_str());
}
	| NEXTSTATE '-' commentstmt { 
		handleNextState(string("-").c_str());
}
;
alternativestmt: altstart cases ENDALTERNATIVE ';' {
			altend();
}	
	| altstart commentstmt cases ENDALTERNATIVE ';' {
			altend();
}
	| altstart cases elsecase ENDALTERNATIVE ';' {
			altend();
}
	| altstart commentstmt cases elsecase ENDALTERNATIVE ';' {
			altend();
}
;
cases: onecase	
	| cases onecase
;
onecase: onecasestart validstmts	{ 
			handleCaseEnd();
}
;
onecasestart: '(' VAR ')' ':' { 
			handleCaseStart(string("(")+string($2)+string(")"));
			PR("Case start");
}
;
elsecase: elsecasestart validstmts {
			handleElseCaseEnd();
}
;
elsecasestart: ELSE ':'	{
			handleElseCaseStart();
}
;
altstart: ALTERNATIVE mqs ';' { 
			handleAltStart(string($2));
}
	| ALTERNATIVE mqs /* allow for syntax errors! */ {
			handleAltStart(string($2));
} 
	| ALTERNATIVE VAR ';' 	/* allow for syntax errors! */ { 
			handleAltStart(string($2));
}
;
callstmt: CALL function ';' { 
			handleCallStmt(0,string($2));
}
	| CALL function commentstmt {
			handleCallStmt(2,string($2));
}	
	| CALL '@' function ';' { 
			handleCallStmt(1,string($3));
}
	| CALL '@' function commentstmt {
			handleCallStmt(3,string($3));
}
;
function: VAR '(' ')' 	{ strcpy($$,string(string($1)+string("()")).c_str());}	
			/*{ strcpy($$,scat((string[]){string($1),string($2),string($3)});}*/
	| VAR '(' args ')' { 
			strcpy($$,string(string($1)+string("(")+string($3)+string(")")).c_str());
			DBG(cout << "Func call" << $$ << endl;)
			}
;
args: VAR		{ 
//				strcpy($$,string(string($1)).c_str());
			}
	| args ',' VAR		{ 
				strcpy($$,string(string($1)+string(",")+string($3)).c_str());
				DBG(cout << "Args: " << $$ << endl;)
				}
;
mqs: MULTIQUOTE {
		strcpy($$,string($1).c_str());
}
	| mqs MULTIQUOTE {
		strcpy($$,string(string($1)+string($2)).c_str());
}
;

%%

extern FILE *yyin;
extern char* yytext;
#include <string>

void PR(string s) {
	cout << s << endl;
}

/*
string scat(string *vals) {
	string out;
	while(*vals!=NULL) {
		out=out+vals++;
	}
	return out;
}
*/

ofstream f_fsmCCOut, f_fsmHOut, f_tmp;

int main(int ac, char **av) {
	
	f_tmp.open("tmp123");
	if(ac>1 && (yyin=fopen(av[1],"r"))==NULL) {
		perror(av[1]);
		exit(1);
	}
	if(!yyparse()) 
		printf("Parser worked.\n");
	else
		printf("Parser failed.\n");
//	cout << *commonHdr << endl;
	f_tmp.close();
	return 0;
} 

void yyerror(char* s)
{
	fprintf(stderr,"%s: %s\n",s, yytext);
}
