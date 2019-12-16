" Single line brief followed by multiline comment.
syn region doxygenComment2 start=+/\*\(\*/\)\@![*!]+ end=+\*/+ contained contains=doxygenSyncStart2,doxygenStart2,doxygenTODO keepend
