module m3::polymorph
/*
Load the Snakes and Ladders game into Rascal and perform some simple analyses.

TO DO:
- replace my utilities by library isInterface() etc
- take abstract classes into account (@modifiers)
- check which constructors are actually called (@invocations)
- check for overrides! (no override => no real polymorphism)
- for dataflow need to look at AST
*/

/* === IMPORTS ===*/

import lang::java::jdt::m3::Core;
import lang::java::m3::TypeHierarchy;
import IO;
import Set;
import List;
import Relation;
import String;
import util::ValueUI;

/* === MODEL ENTITIES === */

@doc { Return the cached snakes model. }
public M3 snakes() = snakesM3;
private M3 snakesM3 = createM3FromEclipseProject(|project://p2-SnakesAndLadders|);

// @memo public M3 snakes() = createM3FromEclipseProject(|project://p2-SnakesAndLadders|);

/* === METHOD STATS === */

@doc { Returns the source URI for the method URI. }
public loc getSource(M3 m, loc method) = getUniqueElement(m@declarations[method]);
@doc { Returns unique element of a set, or fails. }
private &T getUniqueElement(set[&T] s) {
	assert size(s) == 1;
	return getOneFrom(s);
}

@doc { Returns the LOC of the given method. }
public int getMethodLOC(M3 m, loc method) = size(readFileLines(getSource(m, method)));

@doc { Returns a map of methods to LOC. }
public map[loc,int] locPerMethod(M3 m) = ( method : getMethodLOC(m, method) | method <- methods(m) );

// ATERNATIVE avoids reading files
@doc { Returns count of Source Lines of Code for a method or other source entity. }
public int sloc(M3 m, loc elt) {
	loc src = getSource(m,elt);
	return 1 + src.end.line - src.begin.line;
}

/* === SUBTYPES === */

@doc { Return the set of (all) subtypes of a type. }
@memo public set[loc] subtypes(M3 m, loc aType) = invert(getDeclaredTypeHierarchy(m)+)[aType];

/* === POLYMORPHISM DETECTION === */

@doc { Return classes with subclasses and interfaces with >1 implementations. } 
public set[loc] polymorphTypes(M3 m) {
	set[loc] types = getDeclaredTypeHierarchy(m)<0>;
	return { t | t <- types, (isClass(t) && size(subtypes(m,t)) > 0)
							|| (isInterface(t) && size(subtypes(m,t)) > 1) };
}
// polymorphTypes(snakes());

@doc { Returns the type symbol for a given class loc. }
public TypeSymbol getTypeSymbol(M3 m, loc t) = getUniqueElement(m@types[t]);

@doc { Return fields declared to be of polymorphic types. }
public set[loc] polymorphFields(M3 m) {
	set[TypeSymbol] ts = { getTypeSymbol(m,t) | t <- polymorphTypes(m) };
	return { t | t <- invert(m@types)[ts], isField(t) };
}
// polymorphFields(snakes());

/* === TESTS === */

test bool testCountClasses() = size(classes(snakes())) == 10;
test bool testCountInterfaces() = size(interfaces(snakes())) == 1;

private loc dieTestReached = |java+method://p2-SnakesAndLadders/snakes/DieTest/reached(int)|;
test bool testCheckMethodSize() = getMethodLOC(snakes(), dieTestReached) == 9;

test bool testLookUpMethodSize() = locPerMethod(snakes())[dieTestReached] == 9;
test bool testLookUpMethodSize() = sloc(snakes(), dieTestReached) == 9;
test bool testMinLOC() = min(locPerMethod(snakes())<1>) == 1;
test bool testMaxLOC() = max(locPerMethod(snakes())<1>) == 16;


@doc { Test whether the declared classes and interfaces are the same as those listed in the hierarchy. }
test bool testAllClassesFound() {
	set[loc] actual = getDeclaredTypeHierarchy(snakes())<0>;
	set[loc] expected = classes(snakes()) + interfaces(snakes());
	if (expected != actual) {
		text(expected);
		text(actual);
	}
	return expected == actual;
}

private loc squareClass = |java+class://p2-SnakesAndLadders/snakes/Square|;
private loc ladderClass = |java+class://p2-SnakesAndLadders/snakes/Ladder|;
private loc snakeClass = |java+class://p2-SnakesAndLadders/snakes/Snake|;
private loc squareIfc = |java+interface://p2-SnakesAndLadders/snakes/ISquare|;
private loc snakePackage = |java+package://p2-SnakesAndLadders/snakes|;

test bool testCountSquareSubclasses() = size(subtypes(snakes(),squareClass)) == 4;
test bool testCountISquareImplementations() = size(subtypes(snakes(),squareIfc)) == 5;

test bool testIsClass() = isClass(squareClass);
test bool testIsIfc() = isInterface(squareIfc);

test bool testPolymorphTypes() =
	polymorphTypes(snakes()) == { squareIfc, squareClass, ladderClass };

private TypeSymbol snakeClassTS = class(snakeClass,[]);

test bool testGetTS() = getTypeSymbol(snakes(), snakeClass) == snakeClassTS;

private loc squareField = |java+field://p2-SnakesAndLadders/snakes/Player/square|;
test bool testPolymorphFields() = polymorphFields(snakes()) == { squareField };

/* === EOF === */
