pj1: lex.yy.o y.tab.o
	cc lex.yy.o y.tab.o -o scc
y.tab.o: y.tab.c 
	cc -c y.tab.c
lex.yy.o: lex.yy.c y.tab.h
	cc -c lex.yy.c
y.tab.c y.tab.h: pj2.y
	yacc -d pj2.y
lex.yy.c: pj2.l
	flex pj2.l
clean:
	rm lex.yy.o y.tab.o y.tab.c lex.yy.c y.tab.h

