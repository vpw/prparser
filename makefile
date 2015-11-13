#LEX = flex
#YACC = yacc

CCC = c++ -I. 
CC = cc -c

prp: lex.yy.o prp.cc prParseUtils.cc
	$(CCC) lex.yy.o p1.cc prParseUtils.cc -o prp

lex.yy.o: lex.yy.c "prp.cc.h
	$(CC) lex.yy.c -o lex.yy.o

prp.cc "prp.cc.h: prp.y
	$(YACC) -d -o prp.cc prp.y

lex.yy.c: prp.l
	$(LEX) prp.l

clean:
	rm *.o lex.yy.c prp.cc prp.cc.h
