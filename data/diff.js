/*
This is a part of FSWiki.
Moved From plugin/core/Diff.pm FSWiki 3.6.5 to work with
CSP (Content Security Policy) Hash.
*/
function diffUsingJS(type) {
    // get the baseText and newText values from the two textboxes, and split them into lines
    var base   = difflib.stringAsLines(document.getElementById("baseText").value);
    var newtxt = difflib.stringAsLines(document.getElementById("newText").value);

    // create a SequenceMatcher instance that diffs the two sets of lines
    var sm = new difflib.SequenceMatcher(base, newtxt);

    // get the opcodes from the SequenceMatcher instance
    // opcodes is a list of 3-tuples describing what changes should be made to the base text
    // in order to yield the new text
    var opcodes = sm.get_opcodes();
    var diffoutputdiv = document.getElementById("diffoutputdiv")
    while (diffoutputdiv.firstChild) diffoutputdiv.removeChild(diffoutputdiv.firstChild);

    // build the diff view and add it to the current DOM
    diffoutputdiv.appendChild(diffview.buildView({
        baseTextLines: base,
        newTextLines: newtxt,
        opcodes: opcodes,
        // set the display titles for each resource
        baseTextName: "Base Text",
        newTextName: "New Text",
        contextSize: null,
        viewType: type // 1 or 0
    }));
}
