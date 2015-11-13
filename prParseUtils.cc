	return false;
}

void addState(string st) {
	states.PB(st);
	stateMap.insert(pair<string,int>(st,nStates++));
	// Note: States list to be printed in reverse order as per old parser!
	return;
}

bool isInput(string in) {
	for (int i=0; i<inputs.SZ;i++) 
		if (inputs[i]==in) return true;
	return false;
}

		case(ALT):
			f_tmp << "default :\n"  << "{\n" << endl;
		break;
	}
	return;	
}

void prTail(void) {
	prStateList();
	prInputList();
	prStateLine();
	prSTT();
	prFSMDataClass();
	return;
}

void prStateList(void) {
	VS::reverse_iterator rit;
	f_tmp << "/*\n * ---- State list ----\n */" << endl;
	f_tmp << "static const char *fsmStaList_" << svcName << "[] =\n{" << endl;
	for(rit=states.rbegin();rit<states.rend()-1;++rit)
		f_tmp << "\"" << (*rit) << "\"," << endl;
	f_tmp << "\"" << *(states.rend()-1) << "\"\n\n};\n" << endl;
	return;
}

void prInputList(void) {
	VS::reverse_iterator rit;
	f_tmp << "/*\n * ---- Event list ----\n */" << endl;
	f_tmp << "static const char *fsmEvtList_" << svcName << "[] =\n{" << endl;
	for(rit=inputs.rbegin();rit<inputs.rend()-1;++rit)
		f_tmp << "\"" << (*rit) << "\"," << endl;
	f_tmp << "\"" << *(inputs.rend()-1) << "\"\n\n};\n" << endl;
	return;
}

void prStateLine(void) {
	f_tmp << "/*\n * State line table\n */" << endl;
	f_tmp << "static U32 fsmStateLine[] =\n{" << endl;
	int insz=inputs.SZ;
	for(int i=0;i<states.SZ-1;i++) 
		f_tmp << "(U32)" << insz << " * (U32)" << i << "," << endl;
	f_tmp << "(U32)" << insz << " * (U32)" << states.SZ-1 << "\n\n};" << endl;
	return;
}

void prSTT(void) {
	f_tmp << "/*\n * Transition table\n */\n";
	f_tmp << "static P_FSM_TRANS_t fsmTransitions[] =\n{" << endl;
	vector<VS>::reverse_iterator stIt;
	VS::reverse_iterator inIt;
	for(stIt=STT.rbegin()+MAX_STATES-states.SZ;stIt<STT.rend();++stIt) {
	for(inIt=(*stIt).rbegin()+MAX_INPUTS-inputs.SZ;inIt<(*stIt).rend();++inIt)
		f_tmp << (*inIt) << ",";
	f_tmp << endl;
	}
	f_tmp << "\n};\n" << endl;
	return;
}

void prFSMDataClass(void) {
	f_tmp << "/*\n * FSM data class\n */\nFSM_CLASS_t fsmClass_" << svcName << "=\n{" << endl;
	f_tmp << "#if DBG(MAGICS)\n MAGIC_HEAD(FSM_CLASS_t),\n #endif" << endl;
	f_tmp << "(U16)_SOURCE_FILE_ID,        /* Class identifier             */" << endl;
	f_tmp << "\"" << svcName << "\",	 /* Automaton's class name       */" << endl;
	f_tmp << 
	f_tmp << "FALSE,                       /* Class not yet registered     */" << endl;
	f_tmp << "fsmStateLine,              /* State line table           */" << endl;
	f_tmp << "#ifndef RMT_ONLY" << endl;
	f_tmp << "fsmTransitions,              /* Transition's table           */" << endl;
	f_tmp << "#else" << endl;
	f_tmp << "(P_FSM_TRANS_t *)NULL," << endl;
	f_tmp << "#endif /* RMT_ONLY */" << endl;
	f_tmp << "fsmNbSt_tbf,                  /* Number of states             */" << endl;
	f_tmp << "fsmNbEv_tbf,                  /* Number of events             */" << endl;
	f_tmp << "(P_FSM_STARTUP_t)NULL,       /* No entry startup entry point */" << endl;
	f_tmp << "fsmStaList_tbf,               /* ASCII state list             */" << endl;
	f_tmp << "fsmEvtList_tbf,                 /* ASCII event's list           */" << endl;
	f_tmp << "0                             /* Number of instances          */" << endl;
	f_tmp << "" << endl;
	f_tmp << "};" << endl;
	return;	
}
