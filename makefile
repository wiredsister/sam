exec := sam
src := server.ml
pkgs := yojson,lwt.unix,stringext

target: $(src)
	ocamlfind ocamlopt -linkpkg -package $(pkgs) $< -o $(exec) 
