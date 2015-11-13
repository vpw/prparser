#LEX = flex
#YACC = yacc

CCC = c++ -I. 
CC = cc -c

p1: lex.yy.o p1.cc prParseUtils.cc
	$(CCC) lex.yy.o p1.cc prParseUtils.cc -o p1

lex.yy.o: lex.yy.c "p1.cc.h
	$(CC) lex.yy.c -o lex.yy.o

p1.cc "p1.cc.h: p1.y
	$(YACC) -d -o p1.cc p1.y

lex.yy.c: p1.l
	$(LEX) p1.l

clean:
	rm *.o lex.yy.c p1.cc p1.cc.h
