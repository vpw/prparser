%{
/* Definitions */
#include <stdio.h>
/*#include "y.tab.h"*/
#include "p1.cc.h"
#define DBG(X) X

%}

ws [ \t\r]+

%%

{ws} ;
\/\*.*\*\/	{ } 
SERVICE		{ DBG(printf("Service\n");)
			return SERVICE;}
ENDSERVICE	{ return ENDSERVICE;}
START		{ return START;}
STATE		{ return STATE;}
ENDSTATE	{ return ENDSTATE;}
NEXTSTATE	{ return NEXTSTATE;}
INPUT		{ return INPUT;}
CALL 		{ return CALL;}
COMMENT 	{ return COMMENT;} 
ALTERNATIVE 	{ return ALTERNATIVE;}
ENDALTERNATIVE 	{ return ENDALTERNATIVE;}
TASK		{ return TASK;}
JOIN 		{ return JOIN;}
DECISION 	{ return DECISION;}
ENDDECISION	{ return ENDDECISION;}
CONNECTION	{ return CONNECTION;}
ENDCONNECTION	{ return ENDCONNECTION;}
ELSE		{ return ELSE;}
STOP		{ return STOP;}
[(),;@:-]		{ printf("Here");printf("%c\n",yytext[0]); return yytext[0];}
[a-zA-Z0-9_-]+	{ DBG(printf("VAR: %s here\n",yytext);) 
			strcpy(yylval.str,yytext);
			return VAR;}
\'([^\']|\\.)*\'	{ DBG(printf("MQ: %s\n",yytext);)
			strcpy(yylval.str,yytext);
			return MULTIQUOTE;}

%%
#include <stdio.h>
/* User code */

/*
\(\ *[a-zA-Z_-]+\ *\) 	{ DBG(printf("Case\n");)
			return CASE;} 
[a-zA-Z_]+\(([a-zA-Z]+,)*[a-zA-Z]\)		{ DBG(printf("Functioncall\n");)
			return FUNCTIONCALL;}
*/
