.pragma library

function reduceWhitespace(s) {
    return s.replace(/^\s*/, "").replace(/\s*$/, "").replace(/[\b]/g, "").replace(/\n+/g, " ");
}
