var viewStack = [];

function push(view, username, tweetId, listId, listName, eventPage, searchString) {
    viewStack.push({"view": view, "username": username, "tweetid": tweetId, "listid":listId, "listname":listName, "eventpage": eventPage, "searchstring": searchString });
}

function pop() {
    viewStack.pop();
}

function count() {
    return viewStack.length;
}

function clear() {
    viewStack.splice(0, viewStack.length);
}

function clearToBeginning() {
    if (viewStack.length > 1) {
        viewStack.splice(1, viewStack.length-1);
    }
}

function viewName(index) {
    return viewStack[index].view;
}

function tweetId(index) {
    return viewStack[index].tweetid;
}

function username(index) {
    return viewStack[index].username;
}

function eventPage(index) {
    return viewStack[index].eventpage;
}

function listId(index) {
    return viewStack[index].listid;
}

function listName(index) {
    return viewStack[index].listname;
}

function searchString(index) {
    return viewStack[index].searchstring;
}
