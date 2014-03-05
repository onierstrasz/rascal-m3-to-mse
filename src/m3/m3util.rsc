
module m3::m3util

import lang::java::jdt::m3::Core;
import lang::java::m3::TypeHierarchy;
import IO;
import List;

/* === EXPORTING === */

/*
dumpM3(|project://p2-SnakesAndLadders|);
*/

@doc { Write the M3 model for an Eclipse Java project to its source directory. }
public void dumpM3(loc project) {
	M3 m = createM3FromEclipseProject(project);
	loc file = m.id + "<m.id.authority>.m3.txt";
	iprintToFile(file, m);
}

/* === DEBUGGING === */

@doc { Reports where a certain value is found in an M3 model. }
public void whereIs(M3 m, value v) {
	// module analysis::m3::Core
	reportRelPresence(v, m@declarations, "m@declarations");
	reportRelPresence(v, m@types, "m@types");
	reportRelPresence(v, m@uses, "m@uses");
	reportRelPresence(v, m@containment, "m@containment");
	reportPresence(v, toSet(m@messages), "m@messages");
	reportRelPresence(v, m@names, "m@names");
	reportRelPresence(v, m@documentation, "m@documentation");
	reportRelPresence(v, m@modifiers, "m@modifiers");
	
	// module lang::java::m3::Core
	reportRelPresence(v, m@extends, "m@extends");
	reportRelPresence(v, m@implements, "m@implements");
	reportRelPresence(v, m@methodInvocation, "m@methodInvocation");
	reportRelPresence(v, m@fieldAccess, "m@fieldAccess");
	reportRelPresence(v, m@typeDependency, "m@typeDependency");
	reportRelPresence(v, m@methodOverrides, "m@methodOverrides");
}

private void reportRelPresence(value v, rel[value, value] m, str d) {
	reportPresence(v, m<0>, "<d>\<0\>");  
	reportPresence(v, m<1>, "<d>\<1\>");  
}	

private void reportPresence(value v, set[value] s, str d) {
	if (v in s) {
		println("Found <v> in <d>");
	}
}
