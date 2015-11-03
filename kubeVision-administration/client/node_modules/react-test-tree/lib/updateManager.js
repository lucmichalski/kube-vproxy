function UpdateManager (rootElement) {
  this._rootElement = rootElement;
  this._isInternalUpdate = false;
  this._internalUpdateSourceNode = null;
}

UpdateManager.prototype = {

  _handleInternalUpdateEnd: function () {
    this._isInternalUpdate = false;
    this._internalUpdateSourceNode = null;
  },

  nodeHasUpdated: function (node) {
    if (!this._isInternalUpdate) {
      this._internalUpdateSourceNode = node;
      this._isInternalUpdate = true;
      this._rootElement.forceUpdate(this._handleInternalUpdateEnd.bind(this));
    }
  },

  shouldNodeUpdate: function (node) {
    return !this._isInternalUpdate || node !== this._internalUpdateSourceNode;
  }

};

module.exports = UpdateManager;
