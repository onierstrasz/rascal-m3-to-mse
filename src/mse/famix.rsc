/*
A bare-bones FAMIX syntax.  Doesn't take any specific FAMIX entities into account.
*/

module mse::famix

import IO; // println
import String; // endsWith
import util::FileSystem; // crawl

layout Whitespace = [\t-\n\r\ ]* !>> [\t-\n\r\ ] ; // greedy

start syntax Famix
  = "(" Entity* ")"
  ;

syntax Entity
  = "(" EntityName EntityID
      Attribute*
      ")"
  ;

syntax Attribute
  = "(" AttributeName Value+ ")"
  ;

syntax Value
  = String
  | Boolean
  | Number
  | EntityRef
  ;

syntax AttributeName
  = Identifier
  ;

syntax EntityName
  = Identifier
  ;

lexical Identifier
  = [a-zA-Z][a-zA-Z0-9.]* !>> [a-zA-Z0-9.]
  ;

syntax EntityID
  = "(" "id:" ID ")"
  ;

lexical ID
  = [1-9][0-9]* !>> [0-9]
  | [0] !>> [0-9]
  ;

/*
Are there other kinds of numbers?
*/
syntax Number
  = ID
  ;

/*
TODO: handle escaped string chars
*/
lexical String
  = "\'" ![\']* "\'"
  ;

lexical Boolean
  = "true"
  | "false"
  ;
  
syntax EntityRef
  = "(" "ref:" ID ")"
  ;

@doc { Return (recursively) all files within a project. }
public set[loc] allFiles(loc proj) = { f | /file(loc f) := crawl(proj) };

public set[loc] mseFiles(loc proj) = { f | f <- allFiles(proj), endsWith(f.path, ".mse")};

/*
public void parseFiles(loc proj) {
	for (loc f <- mseFiles(proj)) {
		println(f);
		parse(#start[Famix], f);
	}
}
*/

@doc { Return true/false whether all files parse. }
public bool parseFiles(set[loc] files, bool verbose=false) {
	try
		for (loc f <- files) {
			if (verbose) println(f);
			parse(#start[Famix], f);
		}
	catch :
		return false;
	return true;
}

private loc mse = |project://p2-SnakesAndLadders/snakes.mse|;
test bool testSnakes() = parseFiles( { mse } );

test bool testAmbiguity() {
	pt = parse(#start[Famix], mse);
	return !(/amb(_) := pt);
}

/*
loc sp = |project://p2-SnakesAndLadders|;
parseFiles(sp);

mse = |project://p2-SnakesAndLadders/snakes.mse|;
parse(#start[Famix], mse);

*/