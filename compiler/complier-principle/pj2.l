/***************************************************/
/*This is the lexical analyzer for small C language*/
/***************************************************/
%{
#include<stdio.h>
#include<string.h>
#include"y.tab.h"
int flag=0;	/*determine "-" is binary or unary*/
char *terval;	/*to pass the value between lexical and syntax analyzer*/
int linenum=1;	/*recording line number*/
int errtype=-1;	/*recording error type*/
nump=0;		/*recording the number of () [] {}, help to decide error type*/
numb=0;
numc=0;
%}

digit [0-9]	
hexdigit [0-9a-fA-F]
delim [ \t]
delim1 [\n]
ws {delim}+
letter [A-Za-z]
id {letter}({letter}|{digit}|_)*
number {digit}+(\.{digit}+)?(E[+-]?{digit}+)?
%%

{ws} {}
{delim1} {++linenum;}/*caculate line number*/
({digit}*)|(0x({hexdigit}*)) {flag=1;strcpy(terval,"");
if(yytext[0]=='0' && yytext[1]=='x'){sprintf(terval,"%d",strtol(yytext,NULL,16));}
else if(yytext[0]=='0'){sprintf(terval,"%d",strtol(yytext,NULL,8));}
else {sprintf(terval,"%d",strtol(yytext,NULL,10));}
strcat(terval," (INT)");/*fflush(stdout);*//*printf("int: %s\n", yytext);*/return(INT);
}	/*int and 0xint*/

";" {flag=0;
/*printf("semi:  %s\n", yytext);fflush(stdout);*/return(SEMI);
}

"," {flag=0;
/*printf("comma:  %s\n", yytext);fflush(stdout);*/return(COMMA);
}

"-"	{if (flag==1)return MINUS;else return UMINUS;}/*When "-" follows an id, or an int,or ")", or "]", it is binary, otherwise it is unary*/

"!"	{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return LOGICN;}
"++"    {flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return INCRE;}
"--"	{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return DECRE;}
"~"	{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return BITNOT;}
"*"	{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return MULT;}
"/"	{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return DIV;}
"%"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return MOD;}
"+"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return ADD;}
"<<"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return SHIFTL;}
">>"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return SHIFTR;}
">"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return GREATER;}
">="		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return NLESS;}
"<"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return LESS;}
"<="		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return NGREATER;}
"=="		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return EQUAL;}
"!="		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/ return NEQUAL;}
"&"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return BITAND;}
"^"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return BITXOR;}
"|"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return BITOR;}
"&&"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return LOGICAND;}
"||"		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return LOGICOR;}
"+="		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return ADDA;}
"-="		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return MINUSA;}
"*="		{flag=0;/*printf("semi:  %s\n", yytext);fflush(stdout);*/return MULTA;}
"/="		{flag=0;/*printf("  %s\n", yytext);fflush(stdout);*/return DIVA;}
"&="		{flag=0;/*printf(" %s\n", yytext);fflush(stdout);*/return BITANDA;}
"^="		{flag=0;/*printf(" %s\n", yytext);fflush(stdout);*/return BITXORA;}
"|="		{flag=0;/*printf(" %s\n", yytext);fflush(stdout);*/return BITORA;}
"<<="		{flag=0;/*printf("  %s\n", yytext);fflush(stdout);*/return SHIFTLA;}
">>="		{flag=0;/*printf(" %s\n", yytext);fflush(stdout);*/return SHIFTRA;}
"." 		{flag=0;/*printf("%s\n",yytext);fflush(stdout);*/return(DOT);}

int {flag=0;
/*printf("type:  %s\n", yytext);*/strcpy(terval,"");strcat(terval,yytext);strcat(terval," (TYPE)");/*fflush(stdout);*/return(TYPE);
}
write    {flag=0; strcpy(terval,"WRITE: ");strcat(terval,yytext); return WRITE;}
read    {flag=0;  strcpy(terval,"READ: ");strcat(terval,yytext); return READ;}
struct {flag=0;
/*printf("struct: %s\n",yytext);fflush(stdout);*/return(STRUCT);}
"=" {flag=0;
/*printf("assignop:  %s\n", yytext);fflush(stdout);*/return(ASSIGNOP);
}

"(" {flag=0;++nump;
/*printf("lp:  %s\n", yytext);fflush(stdout);*/return(LP);
}

")" {flag=1;--nump;
/*printf("rp:  %s\n", yytext);fflush(stdout);*/return(RP);
}

"[" {flag=0;++numb;
/*printf("lb:  %s\n", yytext);fflush(stdout);*/return(LB);
}

"]" {flag=1;--numb;

/*printf("rb:  %s\n", yytext);fflush(stdout);*/return(RB);
}

"{" {flag=0;++numc;
/*printf("lc:  %s\n", yytext);fflush(stdout);*/return(LC);
}

"}" {flag=0;--numc;
/*printf("rc:  %s\n", yytext);fflush(stdout);*/return(RC);
}

if {flag=0;
/*printf("if:  %s\n", yytext);fflush(stdout);*/return(IF);
}
else {flag=0;
/*printf("else:  %s\n", yytext);fflush(stdout);*/return(ELSE);
}
return {flag=0;
/*printf("return:  %s\n", yytext);fflush(stdout);*/return(RETURN);
}
break {flag=0;
/*printf("semi:  %s\n", yytext);fflush(stdout);*/return(BREAK);
}
continue {flag=0;
/*printf("continue:  %s\n", yytext);fflush(stdout);*/return(CONT);
}

for {flag=0;
/*printf("for:  %s\n", yytext);fflush(stdout);*/return(FOR);
}

{id} {flag=1;
/*printf("id: %s\n", yytext);fflush(stdout);*/strcpy(terval,"");strcat(terval,yytext);strcat(terval," (ID)");return(ID);
}

. {errtype=0;return yytext[0];}	/*deal illegal input*/
%%

