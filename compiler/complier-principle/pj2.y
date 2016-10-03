%{
#include <stdio.h>
#include <string.h>
extern char *terval;	/*passing the content of token(terminial)*/
extern char *yytext;	/*para from lexical analyzer, not being used*/
extern int linenum;	/*store the line num*/
extern int errtype;	/*store the err type*/
extern int nump;	/*number of () [] {},if ( is more than ),then it's positive, else it's 0 or negative*/
extern int numb;
extern int numc;
struct node	/*store the parsing tree*/
{
	char* str;	/*store the content*/
	int linenumber;	/*store the line number of this ter, not being used*/
	struct node* child[10];	/*store the child*/
};
struct symbolnode//elem of symbol table
{
    char* symbolstr;//name
    char type;//type:global,local,addr
    char* arrsize;//array size
    char* structstr;//struct name
    int block;//block number
    int structnum;//struct elem number
    int isvalid;//valid or not
};
struct symbolnode* symbotable[30][30];//index with first letter 
struct node *stk[10000]; /*currently store the node*/
struct node *root; 	/*root node*/
int blocknum=0;//block level
int head=0;	/*head of stk*/
int ispara = 0; //if a fucntion has para
int paraind = 0; //parameters point
char* paraarray[10]; //parametres array
int blocklevel = 0; //depth of stmtblocks
int regnum;//register num, similiar as below
int functionnum;
int ifnum;
int tmpnum=0;
int loopnum;
int arraynum;
int isload = 1; //need to load?
char* arrstr; //array name
char* arrsize; //array size
char* structstring; //struct name
int structnumber; //number of struct elem
char *outputerr;//the file name for output an err
void preorder(struct node* root,int depth)	/*preorder output the tree*/
{
	int k=0;
	for(k=0;k<depth;++k)printf("-");	/*represents level*/
	printf("%s\n",root->str);

	int i = 0;
	
	while (root->child[i]) {preorder(root->child[i],depth+1); i++;}
}

struct node* nter(char* l)	/*build non-terminal node*/
{
    struct node* r;
	r = (struct node*)malloc(sizeof(struct node));
	r->str = (char*)malloc(sizeof(char)*256);
	strcpy(r->str,l);
    	int i;
	for (i=0;i<10;i++) r->child[i] = NULL;
	return r;
};


void inster(struct node* root, char* l)	/*insert terminal node in a node*/
{
	int i=0;
	while (root->child[i]) i++;
	root->child[i] = (struct node*)malloc(sizeof(struct node));
	root->child[i]->str = (char*)malloc(sizeof(char)*256);
	strcpy(root->child[i]->str,l);
    	int k;
	for (k=0;k<10;k++) root->child[i]->child[k] = NULL;
};
struct node* ter(char* pl,char* sl)	/*build terminal node*/
{
    	struct node* p;
	p = nter(pl);
	inster(p,sl);
	p->child[0]->linenumber=linenum;
	return p;
};
void insnter(struct node* root, struct node* a)	/*insert non-terminal node*/
{
    	int i=0;
	while (root->child[i]) i++;
	root->child[i] = a;
};
void yywrap()
{
    return  1;
}
void yyerror(char *s)	/*deal with lexical and syntax errors*/
{
fclose(stdout);
freopen(outputerr,"w",stdout);
printf("Error.");
fclose(stdout);
if(nump<0)errtype=5;
if(numb<0)errtype=6;
if(numc<0)errtype=7;
switch(errtype)
{
case 0: fprintf(stderr,"Error:%s at line %d\n","unexpected character or symbolstr",linenum);break;
case 1:fprintf(stderr,"Error:%s at line %d\n","expect ;",linenum);break;
case 2:fprintf(stderr,"Error:%s at line %d\n","expect )",linenum);break;
case 3:fprintf(stderr,"Error:%s at line %d\n","expect ]",linenum);break;
case 4:fprintf(stderr,"Error:%s at line %d\n","expect }",linenum);break;
case 5:fprintf(stderr,"Error:%s at line %d\n","unexpected (",linenum);break;
case 6:fprintf(stderr,"Error:%s at line %d\n","unexpected ]",linenum);break;
case 7:fprintf(stderr,"Error:%s at line %d\n","unexpected }",linenum);break;
case 8:fprintf(stderr,"Error:%s at line %d\n","expect ;",linenum);break;
default: fprintf(stderr,"Error:%s at line %d\n","Syntax error",linenum);break;
}

exit(1);
}
//*********************************************************************//
void syntax_program(struct node* root);//Function for translation.
void syntax_extdefs(struct node* t);
void syntax_extdef(struct node* t);
void syntax_extvars(struct node* t);
void syntax_declareout(struct node* t);
void syntax_function(struct node* t);
void syntax_paras(struct node* t);
void syntax_para(struct node* t);
void syntax_stmtblock(struct node* t);
void syntax_defs(struct node* t);
void syntax_def(struct node* t);
void syntax_decs(struct node* t);
void syntax_declarein(struct node* t);
void syntax_stmts(struct node* t);
void syntax_stmt(struct node* t);
char* syntax_exp(struct node* t);
void syntax_argsout(struct node* t);
void syntax_argsin(struct node* t);
void syntax_argsfunc(struct node* t);
void syntax_extdefstruct(struct node* t);
void syntax_decstructid(struct node* t);
void syntax_extdefstructid(struct node* t);
void syntax_extvarsstructid(struct node* t);
void syntax_extdefstructop(struct node* t);
void syntax_defsstructop(struct node* t);
void syntax_defstructop(struct node* t);
//*********************************************************************//
 //*********************************************************************//
int main(int argc, char *argv[]) {	/*main function*/
freopen(argv[1],"r",stdin); 
freopen(argv[2],"w",stdout);
outputerr = (char*)malloc(sizeof(char)*100);
strcpy(outputerr, argv[2]);
terval=(char*)malloc(sizeof(char)*256);
yyparse();
//preorder(root,0);
printf("@.str = private unnamed_addr constant [3 x i8] c\"%%d\\00\", align 1\n");//predefine \n
printf("@.str1 = private unnamed_addr constant [2 x i8] c\"\\0A\\00\", align 1\n"); 
syntax_program(root);
printf("\ndeclare i32 @__isoc99_scanf(i8*, ...) #1\n");
printf("declare i32 @printf(i8*, ...) #1\n");
return 0;
}
%}

%token	TYPE STRUCT RETURN IF ELSE BREAK CONT FOR INT ID SEMI COMMA LC RC WRITE READ
%right 	ASSIGNOP ADDA MINUSA MULTA DIVA BITANDA BITXORA BITORA SHIFTLA SHIFTRA
%left	LOGICOR
%left 	LOGICAND
%left	BITOR
%left	BITXOR
%left	BITAND
%left	EQUAL NEQUAL
%left	GREATER LESS NGREATER NLESS
%left	SHIFTL SHIFTR
%left  	ADD MINUS
%left 	MULT DIV MOD
%right	UMINUS LOGICN BITNOT INCRE DECRE
%right 	LB LP
%left   RB RP DOT

%%/*the basic logic is: we parse a terminal and store it in the stack, and when we finished parsing one rule then we build a new node and insert the node we store in the stack before into new node*/
/*We add an ID1->ID to eliminate conflict for project2
we also add write and read for project2 */

PROGRAM		:EXTDEFS{root = nter("PROGRAM"); insnter(root,stk[head--]);}
		;

EXTDEFS		:{stk[++head]=ter("EXTDEFS","NULL");}
		|EXTDEF EXTDEFS{root = nter("EXTDEFS"); insnter(root,stk[head-1]); insnter(root,stk[head]);stk[--head]=root;}
		;

EXTDEF		:SPEC EXTVARS {errtype=8;}SEMI{errtype=-1;}{root = nter("EXTDEF"); insnter(root,stk[head-1]); insnter(root,stk[head]);inster(root,"SEMI");stk[--head]=root;}
		| SPEC FUNC STMTBLOCK{root = nter("EXTDEF"); insnter(root,stk[head-2]);insnter(root,stk[head-1]); insnter(root,stk[head]);head-=2;stk[head]=root;}
		;

EXTVARS		: {stk[++head]=ter("EXTVARS","NULL");}
		| DEC{root=nter("EXTVARS"); insnter(root,stk[head]); stk[head]=root;}
		| DEC COMMA EXTVARS{root = nter("EXTVARS"); insnter(root,stk[head-1]); inster(root,"COMMA");insnter(root,stk[head]);stk[--head]=root;}
		;

SPEC		: TYPE{root=ter("SPEC",terval);  stk[++head]=root;}
		| STSPEC{root=nter("SPEC"); insnter(root,stk[head]); stk[head]=root;}
		;

STSPEC		: STRUCT ID1{root=nter("STSPEC");inster(root,"STRUCT");insnter(root,stk[head]);stk[head]=root;}
		| STRUCT OPTTAG LC DEFS {errtype=4;}RC{errtype=-1;}{root=nter("STSPEC"); inster(root,"STRUCT"); insnter(root,stk[head-1]); inster(root,"LC"); insnter(root,stk[head]);  inster(root,"RC"); stk[--head]=root;}
		;

ID1		:ID{root=ter("ID1",terval);stk[++head]=root;}
		;

OPTTAG		: {stk[++head]=ter("OPTTAG","NULL");}
		| ID1{root=nter("OPTTAG");insnter(root,stk[head]);stk[head]=root;}
		;

VAR		: ID1{root=nter("VAR");insnter(root,stk[head]);stk[head]=root;}
		| VAR LB INT {errtype=3;}RB{errtype=-1;}{root=nter("VAR");insnter(root,stk[head]);inster(root,"LB");inster(root,terval);inster(root,"RB");stk[head]=root;}
		;

FUNC		:ID1 LP PARAS {errtype=2;}RP{errtype=-1;}{root=nter("FUNC");insnter(root,stk[head-1]);inster(root,"LP");insnter(root,stk[head]);inster(root,"RP");stk[--head]=root;}
		;

PARAS		:{stk[++head]=ter("PARAS","NULL");}
		|PARA COMMA PARAS{root=nter("PARAS");insnter(root,stk[head-1]);inster(root,"COMMA");insnter(root,stk[head]);stk[--head]=root;}
		| PARA{root=nter("PARAS");insnter(root,stk[head]);stk[head]=root;}
		;

PARA		:SPEC VAR{root=nter("PARA");insnter(root,stk[head-1]);insnter(root,stk[head]);stk[--head]=root;}
		;

STMTBLOCK	:LC DEFS STMTS {errtype=4;}RC{errtype=-1;}{root=nter("STMTBLOCK");inster(root,"LC");insnter(root,stk[head-1]);insnter(root,stk[head]);inster(root,"RC");stk[--head]=root;}
		;

STMTS		: {stk[++head]=ter("STMTS","NULL");}
		| STMT STMTS{root=nter("STMTS");insnter(root,stk[head-1]);insnter(root,stk[head]);stk[--head]=root;}
		;

STMT		: EXP1 {errtype=8;}SEMI{errtype=-1;}{root=nter("STMT");insnter(root,stk[head]);stk[head]=root;inster(root,"SEMI");}
		| STMTBLOCK{root=nter("STMT");insnter(root,stk[head]);stk[head]=root;}
		| RETURN EXP {errtype=8;}SEMI{errtype=-1;}{root=nter("STMT");inster(root,"RETURN");insnter(root,stk[head]);stk[head]=root;inster(root,"SEMI");}
		| IF LP EXP {errtype=2;}RP{errtype=-1;} STMT ESTMT{root = nter("STMT");inster(root,"IF");inster(root,"LP"); insnter(root,stk[head-2]);inster(root,"RP");insnter(root,stk[head-1]); insnter(root,stk[head]);head-=2;stk[head]=root;}
		| FOR LP EXP1 {errtype=8;}SEMI{errtype=-1;} EXP1 {errtype=8;}SEMI{errtype=-1;} EXP1 {errtype=2;}RP{errtype=-1;} STMT{root = nter("STMT");inster(root,"FOR");inster(root,"LP"); insnter(root,stk[head-3]);inster(root,"SEMI");insnter(root,stk[head-2]);inster(root,"SEMI"); insnter(root,stk[head-1]);inster(root,"RP");insnter(root,stk[head]);head-=3;stk[head]=root;}
		| CONT {errtype=8;}SEMI{errtype=-1;}{root=nter("STMT");inster(root,"CONT");inster(root,"SEMI");stk[++head]=root;}
		| BREAK {errtype=8;}SEMI{errtype=-1;}{root=nter("STMT");inster(root,"BREAK");inster(root,"SEMI");stk[++head]=root;}
		;

ESTMT		:{stk[++head]=ter("ESTMT","NULL");}
		| ELSE STMT{root=nter("ESTMT");inster(root,"ELSE");insnter(root,stk[head]);stk[head]=root;}
		;

DEFS		:{stk[++head]=ter("DEFS","NULL");}
		| DEF DEFS{root=nter("DEFS");insnter(root,stk[head-1]);insnter(root,stk[head]);stk[--head]=root;}
		;

DEF		: SPEC DECS {errtype=8;}SEMI{errtype=-1;}{root=nter("DEF");insnter(root,stk[head-1]);insnter(root,stk[head]);inster(root,"SEMI");stk[--head]=root;}
		;

DECS		:DEC COMMA DECS{root=nter("DECS");insnter(root,stk[head-1]);inster(root,"COMMA");insnter(root,stk[head]);stk[--head]=root;}
		| DEC{root=nter("DECS");insnter(root,stk[head]);stk[head]=root;}
		;

DEC		: VAR{root=nter("DEC");insnter(root,stk[head]);stk[head]=root;}
		| VAR ASSIGNOP INIT{root=nter("DEC");insnter(root,stk[head-1]);inster(root,"ASSIGNOP");insnter(root,stk[head]);stk[--head]=root;}
		;

INIT		: EXP{root=nter("INIT");insnter(root,stk[head]);stk[head]=root;}
		| LC ARGS {errtype=4;}RC{errtype=-1;}{root=nter("INIT");inster(root,"LC");insnter(root,stk[head]);inster(root,"RC");stk[head]=root;}
		;

EXP		: EXP ASSIGNOP EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"ASSIGNOP");insnter(root,stk[head]);stk[--head]=root;}
		| EXP ADD EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"ADD");insnter(root,stk[head]);stk[--head]=root;}
		| EXP MINUS EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"MINUS");insnter(root,stk[head]);stk[--head]=root;}
		| EXP MULT EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"MULT");insnter(root,stk[head]);stk[--head]=root;}
		| EXP DIV EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"DIV");insnter(root,stk[head]);stk[--head]=root;}
		| EXP MOD EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"MOD");insnter(root,stk[head]);stk[--head]=root;}
		| EXP SHIFTLA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"SHIFTLA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP SHIFTRA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"SHIFTRA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP SHIFTL EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"SHIFTL");insnter(root,stk[head]);stk[--head]=root;}
		| EXP SHIFTR EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"SHIFTR");insnter(root,stk[head]);stk[--head]=root;}
		| EXP LESS EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"LESS");insnter(root,stk[head]);stk[--head]=root;}
		| EXP GREATER EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"GREATER");insnter(root,stk[head]);stk[--head]=root;}
		| EXP NGREATER EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"NGREATER");insnter(root,stk[head]);stk[--head]=root;}
		| EXP NLESS EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"NLESS");insnter(root,stk[head]);stk[--head]=root;}
		| EXP EQUAL EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"EQUAL");insnter(root,stk[head]);stk[--head]=root;}
		| EXP NEQUAL EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"NEQUAL");insnter(root,stk[head]);stk[--head]=root;}
		| EXP LOGICAND EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"LOGICAND");insnter(root,stk[head]);stk[--head]=root;}
		| EXP LOGICOR EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"LOGICOR");insnter(root,stk[head]);stk[--head]=root;}
		| EXP BITAND EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"BITAND");insnter(root,stk[head]);stk[--head]=root;}
		| EXP BITXOR EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"BITXOR");insnter(root,stk[head]);stk[--head]=root;}
		| EXP BITOR EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"BITOR");insnter(root,stk[head]);stk[--head]=root;}
		| EXP ADDA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"ADDA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP MINUSA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"MINUSA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP MULTA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"MULTA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP DIVA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"DIVA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP BITANDA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"BITANDA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP BITXORA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"BITXORA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP BITORA EXP{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"BITORA");insnter(root,stk[head]);stk[--head]=root;}
		| INCRE EXP{root=nter("EXP");inster(root,"INCRE");insnter(root,stk[head]);stk[head]=root;}
		| DECRE EXP{root=nter("EXP");inster(root,"DECRE");insnter(root,stk[head]);stk[head]=root;}
		| LOGICN EXP{root=nter("EXP");inster(root,"LOGICN");insnter(root,stk[head]);stk[head]=root;}
		| BITNOT EXP{root=nter("EXP");inster(root,"BITNOT");insnter(root,stk[head]);stk[head]=root;}
		| UMINUS EXP{root=nter("EXP");inster(root,"UMINUS");insnter(root,stk[head]);stk[head]=root;}
		| LP EXP {errtype=2;}RP{errtype=-1;}{root=nter("EXP");inster(root,"LP");insnter(root,stk[head]);inster(root,"RP");stk[head]=root;}
		| ID1 LP ARGS {errtype=2;}RP{errtype=-1;}{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"LP");insnter(root,stk[head]);inster(root,"RP");stk[--head]=root;}
		| ID1 ARRS{root=nter("EXP");insnter(root,stk[head-1]);insnter(root,stk[head]);stk[--head]=root;}
		| EXP DOT ID1{root=nter("EXP");insnter(root,stk[head-1]);inster(root,"DOT");insnter(root,stk[head]);stk[--head]=root;}
		| INT{root=ter("EXP",terval);stk[++head]=root;}
		| WR{root=nter("EXP");insnter(root,stk[head]);stk[head]=root;}
		;

WR		:WRITE LP EXP RP {root=nter("WR"); inster(root,"WRITE"); inster(root,"LP"); insnter(root,stk[head]); inster(root,"RP"); stk[head]=root;}
		|READ LP EXP RP  {root=nter("WR"); inster(root,"READ"); inster(root,"LP"); insnter(root,stk[head]); inster(root,"RP"); stk[head]=root;}
		;

EXP1		:{stk[++head]=ter("EXP1","NULL");}
		| EXP{{root=nter("EXP1");insnter(root,stk[head]);stk[head]=root;}}

ARRS		: {stk[++head]=ter("ARRS","NULL");}
		| LB EXP {errtype=3;}RB{errtype=-1;} ARRS{root=nter("ARRS");inster(root,"LB");insnter(root,stk[head-1]);inster(root,"RB");insnter(root,stk[head]);stk[--head]=root;}
		;

ARGS		:EXP COMMA ARGS{root=nter("ARGS");insnter(root,stk[head-1]);inster(root,"COMMA");insnter(root,stk[head]);stk[--head]=root;}
		| EXP{root=nter("ARGS");insnter(root,stk[head]);stk[head]=root;}
		;
%%
void syntax_program(struct node* root) //PROGRAM
{
    syntax_extdefs(root->child[0]);
    return;
}

void syntax_extdefs(struct node* t) 
{
    if (t->child[1])
    {
        syntax_extdef(t->child[0]);
       syntax_extdefs(t->child[1]);
    }
    return;
}

void syntax_extdef(struct node* t) //external definition
{
    if (t->child[1]->str[0]=='E' && t->child[1]->str[1]=='X') //SPEC EXTVARS SEMI
    {
       if (t->child[0]->child[0]->str[0]=='i') //int
     {
       syntax_extvars(t->child[1]);//go vars
     }
        else //STSPEC
        {
           syntax_extdefstruct(t);//go struct
        }
    }
    else //SPEC FUNC STMTBLOCK
    {
          syntax_function(t->child[1]);//go function
          syntax_stmtblock(t->child[2]);//go stmtblock
    }
    return;
}

void syntax_extvars(struct node* t) //external variables for type
{
    if (t->child[1]==NULL) //DEC
    {
        syntax_declareout(t->child[0]); //external declaration
    }
    else //DEC COMMA EXTVARS
    {
        syntax_declareout(t->child[0]);
        syntax_extvars(t->child[2]);
    }
}

void syntax_declareout(struct node* t) //declartion outside the stmtblock
{
   
    if (t->child[1]==NULL) //VAR
    {
        struct node* nodeVar = t->child[0]; //node of VAR
        if (nodeVar->child[1]==NULL) //int a
        {
            printf("@");
            struct node* tmpnode = nodeVar->child[0]->child[0];/*********************************************/
            int len = strlen(tmpnode->str);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];/*********************************************/
            tmp[i] = '\0';
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
           while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);//*************************check the symbol table to detect an error*************//
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			}++i;}
            symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
            struct symbolnode* s = symbotable[dim1][i];
            s->symbolstr = (char*)malloc(sizeof(char)*60);
            strcpy(s->symbolstr,tmp);
            s->type = 'g';
	    s->block=blocknum;
	    s->isvalid=1;
            printf("%s",tmp);
            printf(" = common global i32 0, align 4\n");
        }
        else //int a[2]
        {
            printf("@");
            struct node* tmpnode = nodeVar->child[0]->child[0]->child[0];
            int len = strlen(tmpnode->str);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
            tmp[i] = '\0';
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);//*************************check the symbol table to detect an error*************//
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}
            symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
            struct symbolnode* s = symbotable[dim1][i];
            s->symbolstr = (char*)malloc(sizeof(char)*60);
            strcpy(s->symbolstr,tmp);
            s->type = 'g';
            s->block=blocknum;
	    s->isvalid=1;
            printf("%s",tmp);
            printf(" = common global [");
            struct node* nodeInt = nodeVar->child[2];
            len = strlen(nodeInt->str);
            i=0; for (i=0;i<len-6;i++) printf("%c",nodeInt->str[i]);

            s->arrsize = (char*)malloc(sizeof(char)*60);
            i=0; for (i=0;i<len-6;i++) s->arrsize[i] = nodeInt->str[i];
	    s->arrsize[i]='\0';
            printf(" x i32] zeroinitializer, align 4\n");
        }
    }
    else 
    {
        struct node* nodeVar = t->child[0]; //node of VAR
        if (nodeVar->child[1]==NULL) // a = 2;
        {
            printf("@");
            struct node* tmpnode = nodeVar->child[0]->child[0];
            int len = strlen(tmpnode->str);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
            tmp[i] = '\0';
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);//*************************check the symbol table to detect an error*************//
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}
            symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
            struct symbolnode* s = symbotable[dim1][i];
            s->symbolstr = (char*)malloc(sizeof(char)*60);
            strcpy(s->symbolstr,tmp);
            s->type = 'g';
            s->block=blocknum;
	    s->isvalid=1;
            printf("%s",tmp);

            struct node* nodeInit = t->child[2]->child[0]->child[0];
            len = strlen(nodeInit->str);
            i=0; for (i=0;i<len-5;i++) tmp[i] = nodeInit->str[i];
	    tmp[i]='\0';
            printf(" = global i32 %s, align 4\n",tmp);
        }
        else // a[3] = {1,2,3}
        {
            printf("@");
            struct node* tmpnode = nodeVar->child[0]->child[0]->child[0];
            int len = strlen(tmpnode->str);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
	    tmp[i] = '\0';
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);//*************************check the symbol table to detect an error*************//
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}
            symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
            struct symbolnode* s = symbotable[dim1][i];
            s->symbolstr = (char*)malloc(sizeof(char)*60);
            strcpy(s->symbolstr,tmp);
            s->type = 'g';
            s->block=blocknum;
	    s->isvalid=1;
            printf("%s",tmp);
            printf(" = global [");
            struct node* nodeInt = nodeVar->child[2];
            len = strlen(nodeInt->str);
            i=0; for (i=0;i<len-6;i++) printf("%c",nodeInt->str[i]);

            s->arrsize = (char*)malloc(sizeof(char)*60);
            i=0; for (i=0;i<len-6;i++) s->arrsize[i] = nodeInt->str[i];
	    s->arrsize[i]='\0';
            printf(" x i32] [");
            syntax_argsout(t->child[2]->child[1]);
            printf("], align 4\n");
        }
    }
}

void syntax_argsout(struct node* t) //extern args
{
    if (t->child[1]==NULL) //EXP
    {
        printf("i32 ");
        char* val = (char*)malloc(sizeof(char)*60);
        val = syntax_exp(t->child[0]);
        printf("%s",val);
    }
    else //EXP COMMA ARGS
    {
        printf("i32 ");
        char* val = (char*)malloc(sizeof(char)*60);
        val = syntax_exp(t->child[0]);
        printf("%s, ",val);
        syntax_argsout(t->child[2]);
    }
}
void syntax_function(struct node* t) //function part:int main(int x, int y)
{
    regnum = functionnum = ifnum = loopnum = arraynum = 0;
    printf("\n");
    //define i32 @dfs(i32 %x) #0 {
    //entry:
    printf("define i32 @");

    struct node* tmpnode = t->child[0]->child[0];
    int len = strlen(tmpnode->str);
    char* tmp = (char*)malloc(sizeof(char)*60);
    int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
    tmp[i] = '\0';
    printf("%s(",tmp);
    if (t->child[2]->child[0]->str[0]=='N') ispara = 0; //PARAS->NULL
    else
    {
         ispara = 1;
        syntax_paras(t->child[2]);
    }
    printf(") #0\n");
}

void syntax_paras(struct node* t) //many parametres
{
    if (t->child[0]->str[0]=='N') {}//do nothing
    else if (t->child[1]) //PARA COMMA PARAS
    {
        syntax_para(t->child[0]);
        printf(", ");
        syntax_paras(t->child[2]);
    }
    else syntax_para(t->child[0]); //PARA
}

void syntax_para(struct node* t) //parametre
{
    struct node* tmpnode = t->child[1]->child[0]->child[0];
    int len = strlen(tmpnode->str);
    char* tmp = (char*)malloc(sizeof(char)*60);
    int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
    tmp[i] = '\0';
    int dim1 = tmp[0]-'a';
    if (dim1<0) dim1 = tmp[0]-'A';
    if (tmp[0]=='_') dim1 = 26;
    i=0;
   while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}
    symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
    struct symbolnode* s = symbotable[dim1][i];
    s->symbolstr = (char*)malloc(sizeof(char)*60);
    strcpy(s->symbolstr,tmp);
    s->type = 'a';
    s->block=blocknum;
    s->isvalid=1;
    printf("i32 %%");
    printf("%s",tmp);
    paraarray[paraind] = (char*)malloc(sizeof(char)*60);
    strcpy(paraarray[paraind],tmp);
    paraind++;
}



void syntax_stmtblock(struct node* t) //statement block
{
    //we need blocklevel to decide whether to print {}
    ++blocknum;//add block level
    if (!blocklevel)
    {
        printf("{\n");
        printf("entry:\n");
    }

    if (ispara)
    {
        int i=0;
        while (paraarray[i])
        {
        printf("  %%%s.addr = alloca i32, align 4\n",paraarray[i]);
         printf("  store i32 %%%s, i32* %%%s.addr, align 4\n",paraarray[i],paraarray[i]);//store the para
         free(paraarray[i]);
        i++;
        }
        ispara = 0;
        paraind = 0;
    }

      syntax_defs(t->child[1]);
      syntax_stmts(t->child[2]);

    if (!blocklevel) printf("}\n");
     int i=0;
     int j=0;
    for(j=0;j<27;++j){i=0;
     while (symbotable[j][i]) {if(symbotable[j][i]->block==blocknum){symbotable[j][i]->isvalid=0;}++i;}//delete useless variable(out of scope)
     }

    --blocknum;//decrease block level
}
void syntax_defs(struct node* t) //definitions
{
    if (t->child[1]==NULL) {}//do nothing
    else
    {
        syntax_def(t->child[0]);
        syntax_defs(t->child[1]);
    }
}

void syntax_def(struct node* t) //definition
{
    syntax_decs(t->child[1]);
}

void syntax_decs(struct node* t) //declaration
{
    if (t->child[1]==NULL) //DEC case
    {
        syntax_declarein(t->child[0]); //the DECs inside the function(local variables)
    }
    else //DEC COMMA DECS case
    {
        syntax_declarein(t->child[0]);
        syntax_decs(t->child[2]);
    }
}

void syntax_declarein(struct node* t)// local declaration
{
    if (t->child[1]==NULL)//int a or int a[3];
    {
        struct node* nodeVar = t->child[0]; 
        if (nodeVar->child[1]==NULL) //int a;
        {
            printf("  %%");
            struct node* tmpnode = nodeVar->child[0]->child[0];
            int len = strlen(tmpnode->str);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
	    tmp[i]='\0';
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}

            symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
            struct symbolnode* s = symbotable[dim1][i];
            s->symbolstr = (char*)malloc(sizeof(char)*60);
            strcpy(s->symbolstr,tmp);
            s->type = 'l';
	    s->block=blocknum;
	    s->isvalid=1;
            printf("%s",tmp);
            printf(" = alloca i32, align 4\n");
        }
        else //int a[3];
        {
            printf("  %%");
            struct node* tmpnode = nodeVar->child[0]->child[0]->child[0];
            int len = strlen(tmpnode->str);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
            tmp[i]='\0';
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}
            symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
            struct symbolnode* s = symbotable[dim1][i];
            s->symbolstr = (char*)malloc(sizeof(char)*60);
            strcpy(s->symbolstr,tmp);
            s->type = 'l';
	    s->block=blocknum;
	    s->isvalid=1;
            printf("%s",tmp);
            printf(" = alloca [");
            struct node* nodeInt = nodeVar->child[2];
            len = strlen(nodeInt->str);
            for (i=0;i<len-5;i++) printf("%c",nodeInt->str[i]);

            s->arrsize = (char*)malloc(sizeof(char)*60);
            for (i=0;i<len-6;i++) s->arrsize[i] = nodeInt->str[i];//////////////////////////////////////////////////////////////
	    s->arrsize[i]='\0';
            printf(" x i32], align 4\n");
        }
    }
    else //int a=1 or int a[3]={1,2,3}
    {
        struct node* nodeVar = t->child[0]; 
        if (nodeVar->child[1]==NULL)
        {
            printf("  %%");
            struct node* tmpnode = nodeVar->child[0]->child[0];
            int len = strlen(tmpnode->str);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
	    tmp[i]='\0';
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}
            symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
            struct symbolnode* s = symbotable[dim1][i];
            s->symbolstr = (char*)malloc(sizeof(char)*60);
            strcpy(s->symbolstr,tmp);
            s->type = 'l';
	    s->block=blocknum;
	    s->isvalid=1;
            printf("%s",tmp);

            char* tmp2 = (char*)malloc(sizeof(char)*60);
	    tmp2=syntax_exp(t->child[2]->child[0]);
            printf(" = alloca i32, align 4\n");
            printf("  store i32 %s, i32* %%%s, align 4\n",tmp2,tmp);
        }
        else 						//a[3] = {1,2,3}
        {
            printf("  %%");
            struct node* tmpnode = nodeVar->child[0]->child[0]->child[0];
            int len = strlen(tmpnode->str);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
	    tmp[i]='\0';
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}
            symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
            struct symbolnode* s = symbotable[dim1][i];
            s->symbolstr = (char*)malloc(sizeof(char)*60);
            strcpy(s->symbolstr,tmp);
            s->type = 'l';
	    s->block=blocknum;
	    s->isvalid=1;
            printf("%s",tmp);
            printf(" = alloca [");
            struct node* nodeInt = nodeVar->child[2];
            len = strlen(nodeInt->str);
            for (i=0;i<len-5;i++) printf("%c",nodeInt->str[i]);
            s->arrsize = (char*)malloc(sizeof(char)*60);
            for (i=0;i<len-6;i++) s->arrsize[i] = nodeInt->str[i];
	    s->arrsize[i]='\0';
            printf(" x i32], align 4\n");

            arrstr = (char*)malloc(sizeof(char)*60);
            arrsize = (char*)malloc(sizeof(char)*60);
            strcpy(arrstr,tmp);
            strcpy(arrsize,s->arrsize);
            syntax_argsin(t->child[2]->child[1]);

            free(arrstr);
            free(arrsize);
        }
    }
}
void syntax_argsin(struct node* t)
{
    //%arrayidx = getelementptr inbounds [2 x i32]* %d, i32 0, i32 0
    //store i32 10, i32* %arrayidx, align 4
    if (t->child[1]==NULL) //EXP
    {
        char* val = (char*)malloc(sizeof(char)*60);
        val = syntax_exp(t->child[0]);
        printf("  %%arrayidx%d = getelementptr inbounds [%s x i32]* %%%s, i32 0, i32 %d\n",arraynum,arrsize,arrstr,arraynum);
        printf("  store i32 %s, i32* %%arrayidx%d, align 4\n",val,arraynum);
        arraynum++;
    }
    else //EXP COMMA ARGS
    {
        char* val = (char*)malloc(sizeof(char)*60);
        val = syntax_exp(t->child[0]);
        printf("  %%arrayidx%d = getelementptr inbounds [%s x i32]* %%%s, i32 0, i32 %d\n",arraynum,arrsize,arrstr,arraynum);
        printf("  store i32 %s, i32* %%arrayidx%d, align 4\n",val,arraynum);
        arraynum++;
        syntax_argsin(t->child[2]);
    }
}
void syntax_stmts(struct node* t) //statements
{
    if (t->child[1]) //STMT STMTS
    {
        syntax_stmt(t->child[0]);
        syntax_stmts(t->child[1]);
    }
    else {} //do nothing
}

void syntax_stmt(struct node* t) //statement
{
    if (t->child[1]==NULL) //STMTBLOCK
    {
        blocklevel++;
        syntax_stmtblock(t->child[0]);
        blocklevel--;
    }
    else if (t->child[0]->str[0]=='E') //EXP SEMI
    {
        syntax_exp(t->child[0]->child[0]);
    }
    else if (t->child[0]->str[0]=='I') //IF
    {
        if (t->child[5]->child[1]!=NULL) //ESTMT not null
        {
            char* tmp = (char*)malloc(sizeof(char)*60);
            tmp = syntax_exp(t->child[2]);
         if (!strcmp(t->child[2]->child[1]->str,"DOT"))
            {
                char *num=(char *)malloc(sizeof(char)*10);
                sprintf(num, "%d", regnum++);
                char* tmpReg = (char*)malloc(sizeof(char)*60);
                strcpy(tmpReg,"%r");
                strcat(tmpReg,num);

                printf("  %s = icmp ne i32 %s, 0\n",tmpReg,tmp);
                strcpy(tmp,tmpReg);
            }
            printf("  br i1 %s, label %%if%d.then, label %%if%d.else\n\n",tmp, ifnum, ifnum);

            printf("if%d.then:\n",ifnum);
            syntax_stmt(t->child[4]);
            printf("  br label %%if%d.end\n\n",ifnum);

            printf("if%d.else:\n",ifnum);
            syntax_stmt(t->child[5]->child[1]);
            printf("  br label %%if%d.end\n\n",ifnum);

            printf("if%d.end:\n",ifnum);

            ifnum++;
        }
        else
        {
            char* tmp = (char*)malloc(sizeof(char)*60);
            tmp = syntax_exp(t->child[2]);


            if (!strcmp(t->child[2]->child[1]->str,"DOT"))
            {
                char *num=(char *)malloc(sizeof(char)*10);
                sprintf(num, "%d", regnum++);
                char* tmpReg = (char*)malloc(sizeof(char)*60);
                strcpy(tmpReg,"%r");
                strcat(tmpReg,num);

                printf("  %s = icmp ne i32 %s, 0\n",tmpReg,tmp);
                strcpy(tmp,tmpReg);
            }

	    
            printf("  br i1 %s, label %%if%d.then, label %%if%d.end\n\n",tmp, ifnum, ifnum);

            printf("if%d.then:\n",ifnum);
            syntax_stmt(t->child[4]);
            printf("  br label %%if%d.end\n\n",ifnum);

            printf("if%d.end:\n",ifnum);

            ifnum++;
        }
    }


    else if (t->child[0]->str[0]=='R') //RETURN EXP SEMI
    {
        printf("  %%r%d = alloca i32, align 4\n",regnum);
        int oldregnum = regnum;
        regnum++;

        char* tmp = (char*)malloc(sizeof(char)*60);
        tmp = syntax_exp(t->child[1]);

        printf("  store i32 %s, i32* %%r%d\n",tmp,oldregnum);
        printf("  %%r%d = load i32* %%r%d\n",regnum,oldregnum);
        printf("  ret i32 %%r%d\n",regnum);
        regnum++;
    }


    else if (t->child[0]->str[0]=='F') //FOR ////////////////////////////empty
    {
        //store i32 0, i32* %i, align 4
        //br label %for.cond
        syntax_exp(t->child[2]->child[0]);
        printf("  br label %%for%d.cond\n\n",loopnum);

        printf("for%d.cond:\n",loopnum);
        char* tmp = (char*)malloc(sizeof(char)*60);
        tmp = syntax_exp(t->child[4]->child[0]);

        //EXP->iNT will crash here!
        if (t->child[4]->child[0]->child[0]->str[2]=='1' && t->child[4]->child[0]->child[1]->str[0]=='A') //special case, ID ARRS
        {
            //%cmp = icmp sgt i32 %0, 16
            printf("  %%r%d = icmp sgt i32 %s, 0",regnum,tmp);
            printf("  br i1 %%r%d, label %%for%d.body, label %%for%d.end\n\n",regnum,loopnum,loopnum);
            regnum++;
        }
        else printf("  br i1 %s, label %%for%d.body, label %%for%d.end\n\n",tmp,loopnum,loopnum);

        printf("for%d.body:\n",loopnum);
        syntax_stmt(t->child[8]);
        printf("  br label %%for%d.inc\n\n",loopnum);

        printf("for%d.inc:\n",loopnum);
        syntax_exp(t->child[6]->child[0]);
        printf("  br label %%for%d.cond\n\n",loopnum);

        printf("for%d.end:\n",loopnum);

        loopnum++;
    }
}
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//
char* syntax_exp(struct node* t)
{
    if(!strcmp(t->str,"NULL"))return NULL;
    int sss = strlen(t->child[0]->str);
    if (t->child[1]==NULL && t->child[0]->str[sss-1]==')'&& t->child[0]->str[sss-2]=='T'&& t->child[0]->str[sss-3]=='N'&& t->child[0]->str[sss-4]=='I') 										//EXP->INT
    {
        char* tmp = (char*)malloc(sizeof(char)*60);
        struct node* nodeInt = t->child[0];
        int len = strlen(nodeInt->str);
        int i; for (i=0;i<len-6;i++) tmp[i] = nodeInt->str[i];
	tmp[i]='\0';
        return tmp;
    }

   
    else if (t->child[0]->str[0]=='I' && t->child[1]->str[0]=='A') //EXP->THEID ARRS
    {
        //printf("%s, %c",symbotable[0][0]->symbolstr,symbotable[0][0]->type);
        //return symbotable[0][0]->symbolstr;

        struct node* nodeArrs = t->child[1];
        if (nodeArrs->child[0]->str[0]=='N') //ARRS->NULL
        {
            char* tmp = (char*)malloc(sizeof(char)*60);
            struct node* tmpnode = t->child[0]->child[0];
            int len = strlen(tmpnode->str);
            int i; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
	    tmp[i]='\0';
            int index = tmp[0]-'a';
            if (index<0) index = tmp[0]-'A';
            if (tmp[0]=='_') index = 26;
            i=0;
            while (symbotable[index][i] && (strcmp(tmp,symbotable[index][i]->symbolstr) || symbotable[index][i]->isvalid==0)) ++i;
	    if(!symbotable[index][i]){fclose(stdout);
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Not a defined variable! (at line %d)\n", tmpnode->str, tmpnode->linenumber);
		        exit(1);}
            struct symbolnode* id = symbotable[index][i];
            if(id->type=='g'){for (i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];tmp[0] = '@';}
            else if(id->type=='l'){for (i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];tmp[0] = '%';}
            else if(id->type=='a'){for (i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];tmp[0] = '%';strcat(tmp,".addr");}
            if (isload)//allocated reg
            {
                char *num=(char *)malloc(sizeof(char)*10);
                sprintf(num, "%d", regnum++);
                char* tmpReg = (char*)malloc(sizeof(char)*60);
                strcpy(tmpReg,"%r");
                strcat(tmpReg,num);

                printf("  %s = load i32* %s, align 4\n",tmpReg,tmp);
                return tmpReg;
            }
            else return tmp; 
        }
        else // return array index
        {
            char* tmp = (char*)malloc(sizeof(char)*60);
            struct node* tmpnode = t->child[0]->child[0];
            int len = strlen(tmpnode->str);
            int i; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
	    tmp[i]='\0';
            
            char* arrsIndex = (char*)malloc(sizeof(char)*60);

           if (isload==0)
            {
                isload = 1;
                arrsIndex = syntax_exp(t->child[1]->child[1]);
                isload = 0;
            }
            else arrsIndex = syntax_exp(t->child[1]->child[1]);
	    
             char* ret = (char*)malloc(sizeof(char)*20);

            strcpy(ret,"%arrayidx");

            char *num[10];

            sprintf(num, "%d", arraynum++);
	 
            strcat(ret,num);
 
            int index = tmp[0]-'a';
            if (index<0) index = tmp[0]-'A';
            if (tmp[0]=='_') index = 26;

            i=0;

     
           while (symbotable[index][i] && (strcmp(tmp,symbotable[index][i]->symbolstr) || symbotable[index][i]->isvalid==0)) ++i;
	    if(!symbotable[index][i]){fclose(stdout);//**************detect undefined variable
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s:undefined variable! (at line %d)\n",tmpnode->str, tmpnode->linenumber);
		        exit(1);}

            struct symbolnode* id = symbotable[index][i];
            switch (id->type)
            {
		
                case 'g':
                for (i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '@';
                break;

                case 'l':
                for (i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '%';
                break;

                case 'a':
                for (i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '%';
                strcat(tmp,".addr");
                break;
            }

            //%arrayidx4 = getelementptr inbounds [2 x i32]* %d, i32 0, i32 1
            printf("  %s = getelementptr inbounds [%s x i32]* %s, i32 0, i32 %s\n",ret,id->arrsize,tmp,arrsIndex);

            if (isload)
            {
                char *num=(char *)malloc(sizeof(char)*10);
                sprintf(num, "%d", regnum++);
                char* tmpReg = (char*)malloc(sizeof(char)*60);
                strcpy(tmpReg,"%r");
                strcat(tmpReg,num);

                printf("  %s = load i32* %s, align 4\n",tmpReg,ret);
                return tmpReg;
            }
            else return ret;
        }
    }
 else if (!strcmp(t->child[0]->str,"WR")) //EXP->WR
    {
        struct node* nodetmpwr = t->child[0];
        if (nodetmpwr->child[0]->str[0]=='W') //WRITE case
        {
            char* tmp = (char*)malloc(sizeof(char)*60);
            tmp = syntax_exp(nodetmpwr->child[2]);
	    printf("  %%call%d = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @.str, i32 0, i32 0), i32 %s)\n",functionnum,tmp);
            functionnum++;
            printf("  %%call%d = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([2 x i8]* @.str1, i32 0, i32 0))\n",functionnum);
            functionnum++;
        }
        else //READ case
        {
            char* tmp = (char*)malloc(sizeof(char)*200);
            isload = 0;
            tmp = syntax_exp(nodetmpwr->child[2]);
            isload = 1;
            printf("  %%call%d = call i32 (i8*, ...)* @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8]* @.str, i32 0, i32 0), i32* %s)\n",functionnum,tmp);
            functionnum++;
        }
        return NULL;
    }
    else if (!strcmp(t->child[0]->str,"INCRE")) //++
    {
        char* op = (char*)malloc(sizeof(char)*60);
        isload = 0;
        op = syntax_exp(t->child[1]);
        isload = 1;

        printf("  %%r%d = load i32* %s, align 4\n",regnum,op);
        printf("  %%r%d = add nsw i32 %%r%d, 1\n",regnum+1,regnum);
        printf("  store i32 %%r%d, i32* %s, align 4\n",regnum+1,op);

        regnum+=2;
        return NULL;
    }
   else if (!strcmp(t->child[0]->str,"DECRE")) //--
    {
        //%27 = load i32* %i, align 4
        //%inc26 = add nsw i32 %27, 1
        //store i32 %inc26, i32* %i, align 4
        char* op = (char*)malloc(sizeof(char)*60);
        isload = 0;
        op = syntax_exp(t->child[1]);
        isload = 1;

        printf("  %%r%d = load i32* %s, align 4\n",regnum,op);
        printf("  %%r%d = sub nsw i32 %%r%d, 1\n",regnum+1,regnum);
        printf("  store i32 %%r%d, i32* %s, align 4\n",regnum+1,op);

        regnum+=2;
        return NULL;
    }
    else if (!strcmp(t->child[0]->str,"UMINUS")) //-
    {
        char* op = (char*)malloc(sizeof(char)*60);
        isload = 0;
        op = syntax_exp(t->child[1]);
        isload = 1;
	if(op[0]=='%' || op[0]=='@')//if reg
	{
        printf("  %%r%d = load i32* %s, align 4\n",regnum,op);
        printf("  %%r%d = sub nsw i32 0, %%r%d\n",regnum+1,regnum);
        printf("  store i32 %%r%d, i32* %s, align 4\n",regnum+1,op);
	char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum+1);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        regnum+=2;
        return tmpReg;
	}
	else//if number
	{
	   char *num=(char *)malloc(sizeof(char)*10);
	   sprintf(num, "%d", -strtol(op,NULL,10));
	   return num;
	}
        
    }
    else if (!strcmp(t->child[0]->str,"LOGICN")) //!
    {
        //%tobool = icmp eq i32 %0, 0
        char* op = (char*)malloc(sizeof(char)*60);
        op = syntax_exp(t->child[1]);

        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = icmp eq i32 %s, 0\n",tmpReg,op);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->str,"ASSIGNOP")) //EXP->EXP ASSIGNOP EXP
    {
        char* op2 = (char*)malloc(sizeof(char)*200);
        strcpy(op2,syntax_exp(t->child[2]));
	
        isload = 0;
        char* op1 = (char*)malloc(sizeof(char)*200);
        strcpy(op1,syntax_exp(t->child[0]));
        isload = 1;

        printf("  store i32 %s, i32* %s, align 4\n",op2,op1);
        return NULL;
    }
    else if (!strcmp(t->child[0]->str,"LP")) //LP EXP RP
    {
        return syntax_exp(t->child[1]);
    }
    else if (!strcmp(t->child[1]->str,"DOT")) ////EXP->EXP DOT THEID
    {
        //%0 = load i32* getelementptr inbounds (%struct.doubleO* @T, i32 0, i32 0), align 4
        struct node* tmpnode = t->child[0]->child[0]->child[0];
        char* tmp = (char*)malloc(sizeof(char)*200);
        int len = strlen(tmpnode->str);
        int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
	tmp[i]='\0';
        int index = tmp[0]-'a';
        if (index<0) index = tmp[0]-'A';
        if (tmp[0]=='_') index = 26;
        i=0;
        while (symbotable[index][i] && (strcmp(tmp,symbotable[index][i]->symbolstr) ||symbotable[index][i]->isvalid==0)) ++i;
	    if(!symbotable[index][i]){fclose(stdout);
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Not a defined structure! (at line %d)\n", tmpnode->str, tmpnode->linenumber);
		        exit(1);}

        struct symbolnode* id = symbotable[index][i];

        char* op1 = (char*)malloc(sizeof(char)*200);
        strcpy(op1,tmp);

        char* opStr = (char*)malloc(sizeof(char)*200);
        strcpy(opStr,id->structstr); //opStr, doubleO

        free(tmp);

        tmpnode = t->child[2]->child[0];
        tmp = (char*)malloc(sizeof(char)*200);
        len = strlen(tmpnode->str);
        i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
        tmp[i]='\0';
        index = tmp[0]-'a';
        if (index<0) index = tmp[0]-'A';
        if (tmp[0]=='_') index = 26;

        i=0;
        while (strcmp(tmp,symbotable[index][i]->symbolstr)) i++;

        id = symbotable[index][i];

        int op2 = id->structnum; //op2

        char* ret = (char*)malloc(sizeof(char)*200);
        strcpy(ret,"getelementptr inbounds (%struct.");
        strcat(ret,opStr);
        strcat(ret,"* @");
        strcat(ret,op1);
        strcat(ret,", i32 0, i32 ");
        char indTmp = '0'+op2;
        char* ind = (char*)malloc(sizeof(char)*50); ind[0] = indTmp; ind[1] = '\0';
        strcat(ret,ind);
        strcat(ret,")");

        if (isload)
        {
            char *num=(char *)malloc(sizeof(char)*10);
            sprintf(num, "%d", regnum++);
            char* tmpReg = (char*)malloc(sizeof(char)*200);
            strcpy(tmpReg,"%r");
            strcat(tmpReg,num);

            printf("  %s = load i32* %s, align 4\n",tmpReg,ret);
            return tmpReg;
        }
        else return ret;
    }
    else if (!strcmp(t->child[1]->str,"EQUAL")) //EXP->EXP EQUAL EXP
    {
        //%cmp = icmp eq i32 %0, %1
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);

        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = icmp eq i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
	
    }
    else if (!strcmp(t->child[1]->str,"GREATER")) //EXP->EXP GREATER EXP
    {
        //%cmp = icmp sgt i32 %0, 16
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);

        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = icmp sgt i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->str,"NGREATER")) //EXP->EXP NGREATER EXP
    {
        //%cmp = icmp sgt i32 %0, 16
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);

        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = icmp sle i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->str,"LESS")) //EXP->EXP LESS EXP
    {
        //%cmp = icmp sgt i32 %0, 16
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);

        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = icmp slt i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->str,"NLESS")) //EXP->EXP NLESS EXP
    {
        //%cmp = icmp sgt i32 %0, 16
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);

        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = icmp sge i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->str,"LOGICAND")) //EXP->EXP LOGICAND EXP
    {
        //%cmp = and eq i32 %0, %1
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);
        int reg1 = regnum, reg2 = regnum+1; regnum+=2;
        printf("  %%r%d = icmp ne i1 %s, 0\n",reg1,op1);
        printf("  %%r%d = icmp ne i1 %s, 0\n",reg2,op2);
        int reg3 = regnum; regnum++;
        printf("  %%r%d = and i1 %%r%d, %%r%d\n",reg3,reg1,reg2);

        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", reg3);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        return tmpReg;
    }
    else if (!strcmp(t->child[1]->str,"ADD")) //EXP ADD EXP
    {
        //%0 = load i32* %a, align 4
        //%1 = load i32* %b, align 4
        //%add = add nsw i32 %0, %1
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);
	
	if(op1[0]!='%' && op1[0]!='@' && op2[0]!='%' && op2[0]!='@')//code optimization: directly caculating the numbers.
	{
	   char *num=(char *)malloc(sizeof(char)*10);
	   sprintf(num, "%d", strtol(op1,NULL,10)+strtol(op2,NULL,10));
	   return num;
	}
	else
	{
        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = add nsw i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
	}
    }
    else if (!strcmp(t->child[1]->str,"MINUS")) //EXP MINUS EXP
    {
        //%0 = load i32* %a, align 4
        //%1 = load i32* %b, align 4
        //%add = add nsw i32 %0, %1
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);
	if(op1[0]!='%' && op1[0]!='@' && op2[0]!='%' && op2[0]!='@')//code optimization: directly caculating the numbers.
	{
	   char *num=(char *)malloc(sizeof(char)*10);
	   sprintf(num, "%d", strtol(op1,NULL,10)-strtol(op2,NULL,10));
	   return num;
	}
	else
	{
        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = sub nsw i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
	}
    }
    else if (!strcmp(t->child[1]->str,"MULT")) //EXP MULT EXP
    {
        //%0 = load i32* %a, align 4
        //%1 = load i32* %b, align 4
        //%add = add nsw i32 %0, %1
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);
	if(op1[0]!='%' && op1[0]!='@' && op2[0]!='%' && op2[0]!='@')//code optimization: directly caculating the numbers.
	{
	   char *num=(char *)malloc(sizeof(char)*10);
	   sprintf(num, "%d", strtol(op1,NULL,10)*strtol(op2,NULL,10));
	   return num;
	}
	else
	{
        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = mul nsw i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
	}
    }
    else if (!strcmp(t->child[1]->str,"DIV")) //EXP DIV EXP
    {
        //%0 = load i32* %a, align 4
        //%1 = load i32* %b, align 4
        //%add = add nsw i32 %0, %1
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);
	if(op1[0]!='%' && op1[0]!='@' && op2[0]!='%' && op2[0]!='@')//code optimization: directly caculating the numbers.
	{
	   char *num=(char *)malloc(sizeof(char)*10);
	   sprintf(num, "%d", strtol(op1,NULL,10)/strtol(op2,NULL,10));
	   return num;
	}
	else
	{
        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = sdiv i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
	}
    }
    else if (!strcmp(t->child[1]->str,"MOD"))//MOD srem
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);
	if(op1[0]!='%' && op1[0]!='@' && op2[0]!='%' && op2[0]!='@')//code optimization: directly caculating the numbers.
	{
	   char *num=(char *)malloc(sizeof(char)*10);
	   sprintf(num, "%d", strtol(op1,NULL,10)%strtol(op2,NULL,10));
	   return num;
	}
	else
	{
        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        printf("  %s = srem i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
	}
    }
    else if (!strcmp(t->child[1]->str,"BITAND"))//BITAND
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);
	if(op1[0]!='%' && op1[0]!='@' && op2[0]!='%' && op2[0]!='@')//code optimization: directly caculating the numbers.
	{
	   char *num=(char *)malloc(sizeof(char)*10);
	   sprintf(num, "%d", strtol(op1,NULL,10)&strtol(op2,NULL,10));
	   return num;
	}
	else
	{
        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpreg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpreg,"%r");
        strcat(tmpreg,num);

        printf("  %s = and i32 %s, %s\n",tmpreg,op1,op2);
        sprintf(num, "%d", regnum++);
        strcpy(tmpreg,"%r");
        strcat(tmpreg,num);

        printf("  %s = icmp ne i32 %%r%d, 0\n",tmpreg,regnum-2);
        return  tmpreg;
	}
    }
    else if (!strcmp(t->child[1]->str,"BITXOR"))//BITXOR
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
        op1 = syntax_exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);
	if(op1[0]!='%' && op1[0]!='@' && op2[0]!='%' && op2[0]!='@')//code optimization: directly caculating the numbers.
	{
	   char *num=(char *)malloc(sizeof(char)*10);
	   sprintf(num, "%d", strtol(op1,NULL,10)^strtol(op2,NULL,10));
	   return num;
	}
	else
	{
        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", regnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);
        printf("  %s = xor i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
	}
    }
    else if (!strcmp(t->child[1]->str,"SHIFTRA")) //EXP SHIFTRA EXP
    {
        //%0 = load i32* %x, align 4
        //%shr = ashr i32 %0, 1
        //store i32 %shr, i32* %x, align 4
        char* op1 = (char*)malloc(sizeof(char)*60);
        isload = 0;
        op1 = syntax_exp(t->child[0]);
        isload = 1;
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);

        printf("%%r%d = load i32* %s, align 4\n",regnum,op1);
        printf("  %%r%d = ashr i32 %%r%d, %s\n",regnum+1,regnum,op2);
        printf("  store i32 %%r%d, i32* %s, align 4\n",regnum+1,op1);
        regnum+=2;
        return NULL;
    }
   else if (!strcmp(t->child[1]->str,"SHIFTLA")) //EXP SHIFTLA EXP
    {
        //%0 = load i32* %x, align 4
        //%shr = ashr i32 %0, 1
        //store i32 %shr, i32* %x, align 4
        char* op1 = (char*)malloc(sizeof(char)*60);
        isload = 0;
        op1 = syntax_exp(t->child[0]);
        isload = 1;
        char* op2 = (char*)malloc(sizeof(char)*60);
        op2 = syntax_exp(t->child[2]);

        printf("%%r%d = load i32* %s, align 4\n",regnum,op1);
        printf("  %%r%d = ashl i32 %%r%d, %s\n",regnum+1,regnum,op2);
        printf("  store i32 %%r%d, i32* %s, align 4\n",regnum+1,op1);
        regnum+=2;
        return NULL;
    }
    else if (!strcmp(t->child[2]->str,"ARGS")) //ID LP ARGS RP
    {
        syntax_argsfunc(t->child[2]);
        char *num=(char *)malloc(sizeof(char)*10);
        sprintf(num, "%d", functionnum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%call");
        strcat(tmpReg,num);

        char* funcName = (char*)malloc(sizeof(char)*60);
        struct node* tmpnode = t->child[0]->child[0];
        int len = strlen(tmpnode->str);
        int i; for (i=0;i<len-5;i++) funcName[i] = tmpnode->str[i];
	funcName[i]='\0';

        printf("  %s = call i32 @%s(",tmpReg,funcName);
        for (i=0;i<paraind-1;i++)
        {
            printf("i32 %s, ",paraarray[i]);
            free(paraarray[i]);
        }
        if (paraind>0)
        {
            printf("i32 %s",paraarray[paraind-1]);
            free(paraarray[i]);
            paraind = 0;
        }
        printf(")\n");

        return tmpReg;
    }
    else return NULL;
}

void syntax_argsfunc(struct node* t) //ARGS for function call
{
    if (t->child[1]==NULL) //EXP
    {
        char* tmp = (char*)malloc(sizeof(char)*60);
        tmp = syntax_exp(t->child[0]);
        paraarray[paraind] = (char*)malloc(sizeof(char)*60);
        strcpy(paraarray[paraind],tmp);
        paraind++;
    }
    else //EXP COMMA ARGS
    {
        char* tmp = (char*)malloc(sizeof(char)*60);
        tmp = syntax_exp(t->child[0]);
        paraarray[paraind] = (char*)malloc(sizeof(char)*60);
        strcpy(paraarray[paraind],tmp);
        paraind++;

        syntax_argsfunc(t->child[2]);
    }
}
void syntax_extdefstruct(struct node* t) //external definition of struct
{
   
    if (t->child[0]->child[0]->child[2]==NULL)//STRUCT ID1
    {
        syntax_extdefstructid(t);
    }
    else syntax_extdefstructop(t);
    return;
}

void syntax_extdefstructop(struct node* t) //STSPEC -> STRUCT OPTTAG LC DEFS RC
{
    struct node* tmpnode = t->child[0]->child[0]->child[1]->child[0]->child[0];

    char* tmp = (char*)malloc(sizeof(char)*200);
    int len = strlen(tmpnode->str);
    int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
    tmp[i] = '\0';
    structnumber = 0;
    printf("%%struct.%s = type { ",tmp);
    syntax_defsstructop(t->child[0]->child[0]->child[3]);
    printf(" }\n");
    structnumber = 0;
}

void syntax_defsstructop(struct node* t) //definitons, for STSPEC -> STRUCT OPTTAG LC DEFS RC case
{
    if (t->child[1]) //DEF DEFS
    {
        syntax_defstructop(t->child[0]);
        structnumber++;
        if (strcmp(t->child[1]->child[0]->str,"NULL")) printf(", ");
        syntax_defsstructop(t->child[1]);
    }
}

void syntax_defstructop(struct node* t) //definiton, for STSPEC -> STRUCT OPTTAG LC DEFS RC case
{
    struct node* tmpnode = t->child[1]->child[0]->child[0]->child[0]->child[0];

    char* tmp = (char*)malloc(sizeof(char)*200);
    int len = strlen(tmpnode->str);
    int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
    tmp[i] = '\0';
    int dim1 = tmp[0]-'a';
    if (dim1<0) dim1 = tmp[0]-'A';
    if (tmp[0]=='_') dim1 = 26;
    i=0;
    while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
	fclose(stdout);
	freopen(outputerr,"w",stdout);
	printf("Error.");
        fclose(stdout);
        fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);exit(1);}i++;}
    symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
    struct symbolnode* s = symbotable[dim1][i];
    s->symbolstr = (char*)malloc(sizeof(char)*200);
    strcpy(s->symbolstr,tmp); 
    s->type='s';
    s->structnum = structnumber;
    printf("i32");
    
}

void syntax_extdefstructid(struct node* t) //external definiton for STRUCT THEID
{
    structstring = (char*)malloc(sizeof(char)*200);

    struct node* tmpnode = t->child[0]->child[0]->child[1]->child[0];
    char* tmp = (char*)malloc(sizeof(char)*200);
    int len = strlen(tmpnode->str);
    int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
    tmp[i] = '\0';
    strcpy(structstring,tmp);

    syntax_extvarsstructid(t->child[1]);

    free(structstring);
}

void syntax_extvarsstructid(struct node* t) //external variables for STRUCT ID
{
    if (t->child[1])
    {
        syntax_decstructid(t->child[0]);
        syntax_extvarsstructid(t->child[2]);
    }
    else syntax_decstructid(t->child[0]);
}

void syntax_decstructid(struct node* t) //declaration for STRUCT ID
{
    struct node* tmpnode = t->child[0]->child[0]->child[0];
    char* tmp = (char*)malloc(sizeof(char)*200);
    int len = strlen(tmpnode->str);
    int i=0; for (i=0;i<len-5;i++) tmp[i] = tmpnode->str[i];
    tmp[i] = '\0';
    int dim1 = tmp[0]-'a';
    if (dim1<0) dim1 = tmp[0]-'A';
    if (tmp[0]=='_') dim1 = 26;
    i=0;
    while (symbotable[dim1][i]){
	if(!strcmp(symbotable[dim1][i]->symbolstr,tmp) && symbotable[dim1][i]->isvalid==1 && symbotable[dim1][i]->block==blocknum){
		fclose(stdout);
	            freopen(outputerr,"w",stdout);
		        printf("Error.");
                fclose(stdout);
             	fprintf(stderr,"%s: Multiple declaration at line %d\n", tmpnode->str,tmpnode->linenumber);
		        exit(1);
			} ++i;}
    symbotable[dim1][i] = (struct symbolnode*)malloc(sizeof(struct symbolnode));
    struct symbolnode* s = symbotable[dim1][i];
    s->symbolstr = (char*)malloc(sizeof(char)*200);
    strcpy(s->symbolstr,tmp);
    s->structstr = (char*)malloc(sizeof(char)*200);
    strcpy(s->structstr,structstring);
    s->type = 'g';
    s->block=blocknum;
    s->isvalid=1;
    printf("@%s",tmp);
    printf(" = common global %%struct.%s zeroinitializer, align 4\n",structstring);
}
