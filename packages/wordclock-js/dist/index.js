(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('react')) :
  typeof define === 'function' && define.amd ? define(['exports', 'react'], factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, factory(global.WordClock = {}, global.React));
}(this, (function (exports, React) { 'use strict';

  function _interopNamespace(e) {
    if (e && e.__esModule) return e;
    var n = Object.create(null);
    if (e) {
      Object.keys(e).forEach(function (k) {
        if (k !== 'default') {
          var d = Object.getOwnPropertyDescriptor(e, k);
          Object.defineProperty(n, k, d.get ? d : {
            enumerable: true,
            get: function () {
              return e[k];
            }
          });
        }
      });
    }
    n['default'] = e;
    return Object.freeze(n);
  }

  var React__namespace = /*#__PURE__*/_interopNamespace(React);

  function _defineProperty(obj, key, value) {
    if (key in obj) {
      Object.defineProperty(obj, key, {
        value: value,
        enumerable: true,
        configurable: true,
        writable: true
      });
    } else {
      obj[key] = value;
    }

    return obj;
  }

  function _arrayWithHoles(arr) {
    if (Array.isArray(arr)) return arr;
  }

  function _iterableToArrayLimit(arr, i) {
    var _i = arr == null ? null : typeof Symbol !== "undefined" && arr[Symbol.iterator] || arr["@@iterator"];

    if (_i == null) return;
    var _arr = [];
    var _n = true;
    var _d = false;

    var _s, _e;

    try {
      for (_i = _i.call(arr); !(_n = (_s = _i.next()).done); _n = true) {
        _arr.push(_s.value);

        if (i && _arr.length === i) break;
      }
    } catch (err) {
      _d = true;
      _e = err;
    } finally {
      try {
        if (!_n && _i["return"] != null) _i["return"]();
      } finally {
        if (_d) throw _e;
      }
    }

    return _arr;
  }

  function _arrayLikeToArray(arr, len) {
    if (len == null || len > arr.length) len = arr.length;

    for (var i = 0, arr2 = new Array(len); i < len; i++) {
      arr2[i] = arr[i];
    }

    return arr2;
  }

  function _unsupportedIterableToArray(o, minLen) {
    if (!o) return;
    if (typeof o === "string") return _arrayLikeToArray(o, minLen);
    var n = Object.prototype.toString.call(o).slice(8, -1);
    if (n === "Object" && o.constructor) n = o.constructor.name;
    if (n === "Map" || n === "Set") return Array.from(o);
    if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen);
  }

  function _nonIterableRest() {
    throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
  }

  function _slicedToArray(arr, i) {
    return _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _unsupportedIterableToArray(arr, i) || _nonIterableRest();
  }

  /**
   * A collection of shims that provide minimal functionality of the ES6 collections.
   *
   * These implementations are not meant to be used outside of the ResizeObserver
   * modules as they cover only a limited range of use cases.
   */

  /* eslint-disable require-jsdoc, valid-jsdoc */
  var MapShim = function () {
    if (typeof Map !== 'undefined') {
      return Map;
    }
    /**
     * Returns index in provided array that matches the specified key.
     *
     * @param {Array<Array>} arr
     * @param {*} key
     * @returns {number}
     */


    function getIndex(arr, key) {
      var result = -1;
      arr.some(function (entry, index) {
        if (entry[0] === key) {
          result = index;
          return true;
        }

        return false;
      });
      return result;
    }

    return function () {
      function class_1() {
        this.__entries__ = [];
      }

      Object.defineProperty(class_1.prototype, "size", {
        /**
         * @returns {boolean}
         */
        get: function () {
          return this.__entries__.length;
        },
        enumerable: true,
        configurable: true
      });
      /**
       * @param {*} key
       * @returns {*}
       */

      class_1.prototype.get = function (key) {
        var index = getIndex(this.__entries__, key);
        var entry = this.__entries__[index];
        return entry && entry[1];
      };
      /**
       * @param {*} key
       * @param {*} value
       * @returns {void}
       */


      class_1.prototype.set = function (key, value) {
        var index = getIndex(this.__entries__, key);

        if (~index) {
          this.__entries__[index][1] = value;
        } else {
          this.__entries__.push([key, value]);
        }
      };
      /**
       * @param {*} key
       * @returns {void}
       */


      class_1.prototype.delete = function (key) {
        var entries = this.__entries__;
        var index = getIndex(entries, key);

        if (~index) {
          entries.splice(index, 1);
        }
      };
      /**
       * @param {*} key
       * @returns {void}
       */


      class_1.prototype.has = function (key) {
        return !!~getIndex(this.__entries__, key);
      };
      /**
       * @returns {void}
       */


      class_1.prototype.clear = function () {
        this.__entries__.splice(0);
      };
      /**
       * @param {Function} callback
       * @param {*} [ctx=null]
       * @returns {void}
       */


      class_1.prototype.forEach = function (callback, ctx) {
        if (ctx === void 0) {
          ctx = null;
        }

        for (var _i = 0, _a = this.__entries__; _i < _a.length; _i++) {
          var entry = _a[_i];
          callback.call(ctx, entry[1], entry[0]);
        }
      };

      return class_1;
    }();
  }();
  /**
   * Detects whether window and document objects are available in current environment.
   */


  var isBrowser = typeof window !== 'undefined' && typeof document !== 'undefined' && window.document === document; // Returns global object of a current environment.

  var global$1 = function () {
    if (typeof global !== 'undefined' && global.Math === Math) {
      return global;
    }

    if (typeof self !== 'undefined' && self.Math === Math) {
      return self;
    }

    if (typeof window !== 'undefined' && window.Math === Math) {
      return window;
    } // eslint-disable-next-line no-new-func


    return Function('return this')();
  }();
  /**
   * A shim for the requestAnimationFrame which falls back to the setTimeout if
   * first one is not supported.
   *
   * @returns {number} Requests' identifier.
   */


  var requestAnimationFrame$1 = function () {
    if (typeof requestAnimationFrame === 'function') {
      // It's required to use a bounded function because IE sometimes throws
      // an "Invalid calling object" error if rAF is invoked without the global
      // object on the left hand side.
      return requestAnimationFrame.bind(global$1);
    }

    return function (callback) {
      return setTimeout(function () {
        return callback(Date.now());
      }, 1000 / 60);
    };
  }(); // Defines minimum timeout before adding a trailing call.


  var trailingTimeout = 2;
  /**
   * Creates a wrapper function which ensures that provided callback will be
   * invoked only once during the specified delay period.
   *
   * @param {Function} callback - Function to be invoked after the delay period.
   * @param {number} delay - Delay after which to invoke callback.
   * @returns {Function}
   */

  function throttle(callback, delay) {
    var leadingCall = false,
        trailingCall = false,
        lastCallTime = 0;
    /**
     * Invokes the original callback function and schedules new invocation if
     * the "proxy" was called during current request.
     *
     * @returns {void}
     */

    function resolvePending() {
      if (leadingCall) {
        leadingCall = false;
        callback();
      }

      if (trailingCall) {
        proxy();
      }
    }
    /**
     * Callback invoked after the specified delay. It will further postpone
     * invocation of the original function delegating it to the
     * requestAnimationFrame.
     *
     * @returns {void}
     */


    function timeoutCallback() {
      requestAnimationFrame$1(resolvePending);
    }
    /**
     * Schedules invocation of the original function.
     *
     * @returns {void}
     */


    function proxy() {
      var timeStamp = Date.now();

      if (leadingCall) {
        // Reject immediately following calls.
        if (timeStamp - lastCallTime < trailingTimeout) {
          return;
        } // Schedule new call to be in invoked when the pending one is resolved.
        // This is important for "transitions" which never actually start
        // immediately so there is a chance that we might miss one if change
        // happens amids the pending invocation.


        trailingCall = true;
      } else {
        leadingCall = true;
        trailingCall = false;
        setTimeout(timeoutCallback, delay);
      }

      lastCallTime = timeStamp;
    }

    return proxy;
  } // Minimum delay before invoking the update of observers.


  var REFRESH_DELAY = 20; // A list of substrings of CSS properties used to find transition events that
  // might affect dimensions of observed elements.

  var transitionKeys = ['top', 'right', 'bottom', 'left', 'width', 'height', 'size', 'weight']; // Check if MutationObserver is available.

  var mutationObserverSupported = typeof MutationObserver !== 'undefined';
  /**
   * Singleton controller class which handles updates of ResizeObserver instances.
   */

  var ResizeObserverController = function () {
    /**
     * Creates a new instance of ResizeObserverController.
     *
     * @private
     */
    function ResizeObserverController() {
      /**
       * Indicates whether DOM listeners have been added.
       *
       * @private {boolean}
       */
      this.connected_ = false;
      /**
       * Tells that controller has subscribed for Mutation Events.
       *
       * @private {boolean}
       */

      this.mutationEventsAdded_ = false;
      /**
       * Keeps reference to the instance of MutationObserver.
       *
       * @private {MutationObserver}
       */

      this.mutationsObserver_ = null;
      /**
       * A list of connected observers.
       *
       * @private {Array<ResizeObserverSPI>}
       */

      this.observers_ = [];
      this.onTransitionEnd_ = this.onTransitionEnd_.bind(this);
      this.refresh = throttle(this.refresh.bind(this), REFRESH_DELAY);
    }
    /**
     * Adds observer to observers list.
     *
     * @param {ResizeObserverSPI} observer - Observer to be added.
     * @returns {void}
     */


    ResizeObserverController.prototype.addObserver = function (observer) {
      if (!~this.observers_.indexOf(observer)) {
        this.observers_.push(observer);
      } // Add listeners if they haven't been added yet.


      if (!this.connected_) {
        this.connect_();
      }
    };
    /**
     * Removes observer from observers list.
     *
     * @param {ResizeObserverSPI} observer - Observer to be removed.
     * @returns {void}
     */


    ResizeObserverController.prototype.removeObserver = function (observer) {
      var observers = this.observers_;
      var index = observers.indexOf(observer); // Remove observer if it's present in registry.

      if (~index) {
        observers.splice(index, 1);
      } // Remove listeners if controller has no connected observers.


      if (!observers.length && this.connected_) {
        this.disconnect_();
      }
    };
    /**
     * Invokes the update of observers. It will continue running updates insofar
     * it detects changes.
     *
     * @returns {void}
     */


    ResizeObserverController.prototype.refresh = function () {
      var changesDetected = this.updateObservers_(); // Continue running updates if changes have been detected as there might
      // be future ones caused by CSS transitions.

      if (changesDetected) {
        this.refresh();
      }
    };
    /**
     * Updates every observer from observers list and notifies them of queued
     * entries.
     *
     * @private
     * @returns {boolean} Returns "true" if any observer has detected changes in
     *      dimensions of it's elements.
     */


    ResizeObserverController.prototype.updateObservers_ = function () {
      // Collect observers that have active observations.
      var activeObservers = this.observers_.filter(function (observer) {
        return observer.gatherActive(), observer.hasActive();
      }); // Deliver notifications in a separate cycle in order to avoid any
      // collisions between observers, e.g. when multiple instances of
      // ResizeObserver are tracking the same element and the callback of one
      // of them changes content dimensions of the observed target. Sometimes
      // this may result in notifications being blocked for the rest of observers.

      activeObservers.forEach(function (observer) {
        return observer.broadcastActive();
      });
      return activeObservers.length > 0;
    };
    /**
     * Initializes DOM listeners.
     *
     * @private
     * @returns {void}
     */


    ResizeObserverController.prototype.connect_ = function () {
      // Do nothing if running in a non-browser environment or if listeners
      // have been already added.
      if (!isBrowser || this.connected_) {
        return;
      } // Subscription to the "Transitionend" event is used as a workaround for
      // delayed transitions. This way it's possible to capture at least the
      // final state of an element.


      document.addEventListener('transitionend', this.onTransitionEnd_);
      window.addEventListener('resize', this.refresh);

      if (mutationObserverSupported) {
        this.mutationsObserver_ = new MutationObserver(this.refresh);
        this.mutationsObserver_.observe(document, {
          attributes: true,
          childList: true,
          characterData: true,
          subtree: true
        });
      } else {
        document.addEventListener('DOMSubtreeModified', this.refresh);
        this.mutationEventsAdded_ = true;
      }

      this.connected_ = true;
    };
    /**
     * Removes DOM listeners.
     *
     * @private
     * @returns {void}
     */


    ResizeObserverController.prototype.disconnect_ = function () {
      // Do nothing if running in a non-browser environment or if listeners
      // have been already removed.
      if (!isBrowser || !this.connected_) {
        return;
      }

      document.removeEventListener('transitionend', this.onTransitionEnd_);
      window.removeEventListener('resize', this.refresh);

      if (this.mutationsObserver_) {
        this.mutationsObserver_.disconnect();
      }

      if (this.mutationEventsAdded_) {
        document.removeEventListener('DOMSubtreeModified', this.refresh);
      }

      this.mutationsObserver_ = null;
      this.mutationEventsAdded_ = false;
      this.connected_ = false;
    };
    /**
     * "Transitionend" event handler.
     *
     * @private
     * @param {TransitionEvent} event
     * @returns {void}
     */


    ResizeObserverController.prototype.onTransitionEnd_ = function (_a) {
      var _b = _a.propertyName,
          propertyName = _b === void 0 ? '' : _b; // Detect whether transition may affect dimensions of an element.

      var isReflowProperty = transitionKeys.some(function (key) {
        return !!~propertyName.indexOf(key);
      });

      if (isReflowProperty) {
        this.refresh();
      }
    };
    /**
     * Returns instance of the ResizeObserverController.
     *
     * @returns {ResizeObserverController}
     */


    ResizeObserverController.getInstance = function () {
      if (!this.instance_) {
        this.instance_ = new ResizeObserverController();
      }

      return this.instance_;
    };
    /**
     * Holds reference to the controller's instance.
     *
     * @private {ResizeObserverController}
     */


    ResizeObserverController.instance_ = null;
    return ResizeObserverController;
  }();
  /**
   * Defines non-writable/enumerable properties of the provided target object.
   *
   * @param {Object} target - Object for which to define properties.
   * @param {Object} props - Properties to be defined.
   * @returns {Object} Target object.
   */


  var defineConfigurable = function (target, props) {
    for (var _i = 0, _a = Object.keys(props); _i < _a.length; _i++) {
      var key = _a[_i];
      Object.defineProperty(target, key, {
        value: props[key],
        enumerable: false,
        writable: false,
        configurable: true
      });
    }

    return target;
  };
  /**
   * Returns the global object associated with provided element.
   *
   * @param {Object} target
   * @returns {Object}
   */


  var getWindowOf = function (target) {
    // Assume that the element is an instance of Node, which means that it
    // has the "ownerDocument" property from which we can retrieve a
    // corresponding global object.
    var ownerGlobal = target && target.ownerDocument && target.ownerDocument.defaultView; // Return the local global object if it's not possible extract one from
    // provided element.

    return ownerGlobal || global$1;
  }; // Placeholder of an empty content rectangle.


  var emptyRect = createRectInit(0, 0, 0, 0);
  /**
   * Converts provided string to a number.
   *
   * @param {number|string} value
   * @returns {number}
   */

  function toFloat(value) {
    return parseFloat(value) || 0;
  }
  /**
   * Extracts borders size from provided styles.
   *
   * @param {CSSStyleDeclaration} styles
   * @param {...string} positions - Borders positions (top, right, ...)
   * @returns {number}
   */


  function getBordersSize(styles) {
    var positions = [];

    for (var _i = 1; _i < arguments.length; _i++) {
      positions[_i - 1] = arguments[_i];
    }

    return positions.reduce(function (size, position) {
      var value = styles['border-' + position + '-width'];
      return size + toFloat(value);
    }, 0);
  }
  /**
   * Extracts paddings sizes from provided styles.
   *
   * @param {CSSStyleDeclaration} styles
   * @returns {Object} Paddings box.
   */


  function getPaddings(styles) {
    var positions = ['top', 'right', 'bottom', 'left'];
    var paddings = {};

    for (var _i = 0, positions_1 = positions; _i < positions_1.length; _i++) {
      var position = positions_1[_i];
      var value = styles['padding-' + position];
      paddings[position] = toFloat(value);
    }

    return paddings;
  }
  /**
   * Calculates content rectangle of provided SVG element.
   *
   * @param {SVGGraphicsElement} target - Element content rectangle of which needs
   *      to be calculated.
   * @returns {DOMRectInit}
   */


  function getSVGContentRect(target) {
    var bbox = target.getBBox();
    return createRectInit(0, 0, bbox.width, bbox.height);
  }
  /**
   * Calculates content rectangle of provided HTMLElement.
   *
   * @param {HTMLElement} target - Element for which to calculate the content rectangle.
   * @returns {DOMRectInit}
   */


  function getHTMLElementContentRect(target) {
    // Client width & height properties can't be
    // used exclusively as they provide rounded values.
    var clientWidth = target.clientWidth,
        clientHeight = target.clientHeight; // By this condition we can catch all non-replaced inline, hidden and
    // detached elements. Though elements with width & height properties less
    // than 0.5 will be discarded as well.
    //
    // Without it we would need to implement separate methods for each of
    // those cases and it's not possible to perform a precise and performance
    // effective test for hidden elements. E.g. even jQuery's ':visible' filter
    // gives wrong results for elements with width & height less than 0.5.

    if (!clientWidth && !clientHeight) {
      return emptyRect;
    }

    var styles = getWindowOf(target).getComputedStyle(target);
    var paddings = getPaddings(styles);
    var horizPad = paddings.left + paddings.right;
    var vertPad = paddings.top + paddings.bottom; // Computed styles of width & height are being used because they are the
    // only dimensions available to JS that contain non-rounded values. It could
    // be possible to utilize the getBoundingClientRect if only it's data wasn't
    // affected by CSS transformations let alone paddings, borders and scroll bars.

    var width = toFloat(styles.width),
        height = toFloat(styles.height); // Width & height include paddings and borders when the 'border-box' box
    // model is applied (except for IE).

    if (styles.boxSizing === 'border-box') {
      // Following conditions are required to handle Internet Explorer which
      // doesn't include paddings and borders to computed CSS dimensions.
      //
      // We can say that if CSS dimensions + paddings are equal to the "client"
      // properties then it's either IE, and thus we don't need to subtract
      // anything, or an element merely doesn't have paddings/borders styles.
      if (Math.round(width + horizPad) !== clientWidth) {
        width -= getBordersSize(styles, 'left', 'right') + horizPad;
      }

      if (Math.round(height + vertPad) !== clientHeight) {
        height -= getBordersSize(styles, 'top', 'bottom') + vertPad;
      }
    } // Following steps can't be applied to the document's root element as its
    // client[Width/Height] properties represent viewport area of the window.
    // Besides, it's as well not necessary as the <html> itself neither has
    // rendered scroll bars nor it can be clipped.


    if (!isDocumentElement(target)) {
      // In some browsers (only in Firefox, actually) CSS width & height
      // include scroll bars size which can be removed at this step as scroll
      // bars are the only difference between rounded dimensions + paddings
      // and "client" properties, though that is not always true in Chrome.
      var vertScrollbar = Math.round(width + horizPad) - clientWidth;
      var horizScrollbar = Math.round(height + vertPad) - clientHeight; // Chrome has a rather weird rounding of "client" properties.
      // E.g. for an element with content width of 314.2px it sometimes gives
      // the client width of 315px and for the width of 314.7px it may give
      // 314px. And it doesn't happen all the time. So just ignore this delta
      // as a non-relevant.

      if (Math.abs(vertScrollbar) !== 1) {
        width -= vertScrollbar;
      }

      if (Math.abs(horizScrollbar) !== 1) {
        height -= horizScrollbar;
      }
    }

    return createRectInit(paddings.left, paddings.top, width, height);
  }
  /**
   * Checks whether provided element is an instance of the SVGGraphicsElement.
   *
   * @param {Element} target - Element to be checked.
   * @returns {boolean}
   */


  var isSVGGraphicsElement = function () {
    // Some browsers, namely IE and Edge, don't have the SVGGraphicsElement
    // interface.
    if (typeof SVGGraphicsElement !== 'undefined') {
      return function (target) {
        return target instanceof getWindowOf(target).SVGGraphicsElement;
      };
    } // If it's so, then check that element is at least an instance of the
    // SVGElement and that it has the "getBBox" method.
    // eslint-disable-next-line no-extra-parens


    return function (target) {
      return target instanceof getWindowOf(target).SVGElement && typeof target.getBBox === 'function';
    };
  }();
  /**
   * Checks whether provided element is a document element (<html>).
   *
   * @param {Element} target - Element to be checked.
   * @returns {boolean}
   */


  function isDocumentElement(target) {
    return target === getWindowOf(target).document.documentElement;
  }
  /**
   * Calculates an appropriate content rectangle for provided html or svg element.
   *
   * @param {Element} target - Element content rectangle of which needs to be calculated.
   * @returns {DOMRectInit}
   */


  function getContentRect(target) {
    if (!isBrowser) {
      return emptyRect;
    }

    if (isSVGGraphicsElement(target)) {
      return getSVGContentRect(target);
    }

    return getHTMLElementContentRect(target);
  }
  /**
   * Creates rectangle with an interface of the DOMRectReadOnly.
   * Spec: https://drafts.fxtf.org/geometry/#domrectreadonly
   *
   * @param {DOMRectInit} rectInit - Object with rectangle's x/y coordinates and dimensions.
   * @returns {DOMRectReadOnly}
   */


  function createReadOnlyRect(_a) {
    var x = _a.x,
        y = _a.y,
        width = _a.width,
        height = _a.height; // If DOMRectReadOnly is available use it as a prototype for the rectangle.

    var Constr = typeof DOMRectReadOnly !== 'undefined' ? DOMRectReadOnly : Object;
    var rect = Object.create(Constr.prototype); // Rectangle's properties are not writable and non-enumerable.

    defineConfigurable(rect, {
      x: x,
      y: y,
      width: width,
      height: height,
      top: y,
      right: x + width,
      bottom: height + y,
      left: x
    });
    return rect;
  }
  /**
   * Creates DOMRectInit object based on the provided dimensions and the x/y coordinates.
   * Spec: https://drafts.fxtf.org/geometry/#dictdef-domrectinit
   *
   * @param {number} x - X coordinate.
   * @param {number} y - Y coordinate.
   * @param {number} width - Rectangle's width.
   * @param {number} height - Rectangle's height.
   * @returns {DOMRectInit}
   */


  function createRectInit(x, y, width, height) {
    return {
      x: x,
      y: y,
      width: width,
      height: height
    };
  }
  /**
   * Class that is responsible for computations of the content rectangle of
   * provided DOM element and for keeping track of it's changes.
   */


  var ResizeObservation = function () {
    /**
     * Creates an instance of ResizeObservation.
     *
     * @param {Element} target - Element to be observed.
     */
    function ResizeObservation(target) {
      /**
       * Broadcasted width of content rectangle.
       *
       * @type {number}
       */
      this.broadcastWidth = 0;
      /**
       * Broadcasted height of content rectangle.
       *
       * @type {number}
       */

      this.broadcastHeight = 0;
      /**
       * Reference to the last observed content rectangle.
       *
       * @private {DOMRectInit}
       */

      this.contentRect_ = createRectInit(0, 0, 0, 0);
      this.target = target;
    }
    /**
     * Updates content rectangle and tells whether it's width or height properties
     * have changed since the last broadcast.
     *
     * @returns {boolean}
     */


    ResizeObservation.prototype.isActive = function () {
      var rect = getContentRect(this.target);
      this.contentRect_ = rect;
      return rect.width !== this.broadcastWidth || rect.height !== this.broadcastHeight;
    };
    /**
     * Updates 'broadcastWidth' and 'broadcastHeight' properties with a data
     * from the corresponding properties of the last observed content rectangle.
     *
     * @returns {DOMRectInit} Last observed content rectangle.
     */


    ResizeObservation.prototype.broadcastRect = function () {
      var rect = this.contentRect_;
      this.broadcastWidth = rect.width;
      this.broadcastHeight = rect.height;
      return rect;
    };

    return ResizeObservation;
  }();

  var ResizeObserverEntry = function () {
    /**
     * Creates an instance of ResizeObserverEntry.
     *
     * @param {Element} target - Element that is being observed.
     * @param {DOMRectInit} rectInit - Data of the element's content rectangle.
     */
    function ResizeObserverEntry(target, rectInit) {
      var contentRect = createReadOnlyRect(rectInit); // According to the specification following properties are not writable
      // and are also not enumerable in the native implementation.
      //
      // Property accessors are not being used as they'd require to define a
      // private WeakMap storage which may cause memory leaks in browsers that
      // don't support this type of collections.

      defineConfigurable(this, {
        target: target,
        contentRect: contentRect
      });
    }

    return ResizeObserverEntry;
  }();

  var ResizeObserverSPI = function () {
    /**
     * Creates a new instance of ResizeObserver.
     *
     * @param {ResizeObserverCallback} callback - Callback function that is invoked
     *      when one of the observed elements changes it's content dimensions.
     * @param {ResizeObserverController} controller - Controller instance which
     *      is responsible for the updates of observer.
     * @param {ResizeObserver} callbackCtx - Reference to the public
     *      ResizeObserver instance which will be passed to callback function.
     */
    function ResizeObserverSPI(callback, controller, callbackCtx) {
      /**
       * Collection of resize observations that have detected changes in dimensions
       * of elements.
       *
       * @private {Array<ResizeObservation>}
       */
      this.activeObservations_ = [];
      /**
       * Registry of the ResizeObservation instances.
       *
       * @private {Map<Element, ResizeObservation>}
       */

      this.observations_ = new MapShim();

      if (typeof callback !== 'function') {
        throw new TypeError('The callback provided as parameter 1 is not a function.');
      }

      this.callback_ = callback;
      this.controller_ = controller;
      this.callbackCtx_ = callbackCtx;
    }
    /**
     * Starts observing provided element.
     *
     * @param {Element} target - Element to be observed.
     * @returns {void}
     */


    ResizeObserverSPI.prototype.observe = function (target) {
      if (!arguments.length) {
        throw new TypeError('1 argument required, but only 0 present.');
      } // Do nothing if current environment doesn't have the Element interface.


      if (typeof Element === 'undefined' || !(Element instanceof Object)) {
        return;
      }

      if (!(target instanceof getWindowOf(target).Element)) {
        throw new TypeError('parameter 1 is not of type "Element".');
      }

      var observations = this.observations_; // Do nothing if element is already being observed.

      if (observations.has(target)) {
        return;
      }

      observations.set(target, new ResizeObservation(target));
      this.controller_.addObserver(this); // Force the update of observations.

      this.controller_.refresh();
    };
    /**
     * Stops observing provided element.
     *
     * @param {Element} target - Element to stop observing.
     * @returns {void}
     */


    ResizeObserverSPI.prototype.unobserve = function (target) {
      if (!arguments.length) {
        throw new TypeError('1 argument required, but only 0 present.');
      } // Do nothing if current environment doesn't have the Element interface.


      if (typeof Element === 'undefined' || !(Element instanceof Object)) {
        return;
      }

      if (!(target instanceof getWindowOf(target).Element)) {
        throw new TypeError('parameter 1 is not of type "Element".');
      }

      var observations = this.observations_; // Do nothing if element is not being observed.

      if (!observations.has(target)) {
        return;
      }

      observations.delete(target);

      if (!observations.size) {
        this.controller_.removeObserver(this);
      }
    };
    /**
     * Stops observing all elements.
     *
     * @returns {void}
     */


    ResizeObserverSPI.prototype.disconnect = function () {
      this.clearActive();
      this.observations_.clear();
      this.controller_.removeObserver(this);
    };
    /**
     * Collects observation instances the associated element of which has changed
     * it's content rectangle.
     *
     * @returns {void}
     */


    ResizeObserverSPI.prototype.gatherActive = function () {
      var _this = this;

      this.clearActive();
      this.observations_.forEach(function (observation) {
        if (observation.isActive()) {
          _this.activeObservations_.push(observation);
        }
      });
    };
    /**
     * Invokes initial callback function with a list of ResizeObserverEntry
     * instances collected from active resize observations.
     *
     * @returns {void}
     */


    ResizeObserverSPI.prototype.broadcastActive = function () {
      // Do nothing if observer doesn't have active observations.
      if (!this.hasActive()) {
        return;
      }

      var ctx = this.callbackCtx_; // Create ResizeObserverEntry instance for every active observation.

      var entries = this.activeObservations_.map(function (observation) {
        return new ResizeObserverEntry(observation.target, observation.broadcastRect());
      });
      this.callback_.call(ctx, entries, ctx);
      this.clearActive();
    };
    /**
     * Clears the collection of active observations.
     *
     * @returns {void}
     */


    ResizeObserverSPI.prototype.clearActive = function () {
      this.activeObservations_.splice(0);
    };
    /**
     * Tells whether observer has active observations.
     *
     * @returns {boolean}
     */


    ResizeObserverSPI.prototype.hasActive = function () {
      return this.activeObservations_.length > 0;
    };

    return ResizeObserverSPI;
  }(); // Registry of internal observers. If WeakMap is not available use current shim
  // for the Map collection as it has all required methods and because WeakMap
  // can't be fully polyfilled anyway.


  var observers = typeof WeakMap !== 'undefined' ? new WeakMap() : new MapShim();
  /**
   * ResizeObserver API. Encapsulates the ResizeObserver SPI implementation
   * exposing only those methods and properties that are defined in the spec.
   */

  var ResizeObserver = function () {
    /**
     * Creates a new instance of ResizeObserver.
     *
     * @param {ResizeObserverCallback} callback - Callback that is invoked when
     *      dimensions of the observed elements change.
     */
    function ResizeObserver(callback) {
      if (!(this instanceof ResizeObserver)) {
        throw new TypeError('Cannot call a class as a function.');
      }

      if (!arguments.length) {
        throw new TypeError('1 argument required, but only 0 present.');
      }

      var controller = ResizeObserverController.getInstance();
      var observer = new ResizeObserverSPI(callback, controller, this);
      observers.set(this, observer);
    }

    return ResizeObserver;
  }(); // Expose public methods of ResizeObserver.


  ['observe', 'unobserve', 'disconnect'].forEach(function (method) {
    ResizeObserver.prototype[method] = function () {
      var _a;

      return (_a = observers.get(this))[method].apply(_a, arguments);
    };
  });

  var index = function () {
    // Export existing implementation if available.
    if (typeof global$1.ResizeObserver !== 'undefined') {
      return global$1.ResizeObserver;
    }

    return ResizeObserver;
  }();

  const getTimeProps = dateInstance => {
    if (dateInstance === undefined) {
      dateInstance = new Date();
    }

    const day = dateInstance.getDay();
    let daystartingmonday = day - 1;

    while (daystartingmonday < 0) {
      daystartingmonday += 7;
    }

    const date = dateInstance.getDate();
    const month = dateInstance.getMonth();
    const hour = dateInstance.getHours() % 12;
    const twentyfourhour = dateInstance.getHours();
    const minute = dateInstance.getMinutes();
    const second = dateInstance.getSeconds();
    return {
      day,
      daystartingmonday,
      date,
      month,
      hour,
      twentyfourhour,
      minute,
      second
    };
  };

  const useTimeProps = () => {
    const [timeProps, setTimeProps] = React__namespace.useState(getTimeProps());
    React__namespace.useEffect(() => {
      const interval = setInterval(() => {
        setTimeProps(getTimeProps());
      }, 1000);
      return () => clearInterval(interval);
    }, []);
    return timeProps;
  };

  var parseJson = function parseJson(_ref) {
    var groups = _ref.groups;
    var label = [];
    var logic = [];
    groups.forEach(function (group) {
      var groupLabel = [];
      var groupLogic = [];
      group.forEach(function (entry) {
        var type = entry.type;

        if (type === "item") {
          var items = entry.items;
          items.forEach(function (item) {
            var _item$text;

            var highlight = item.highlight;
            var text = (_item$text = item.text) !== null && _item$text !== void 0 ? _item$text : "";
            groupLabel.push(text);
            groupLogic.push(highlight);
          });
        } else if (type === "sequence") {
          var bind = entry.bind;
          var first = entry.first;
          var textArray = entry.text;
          textArray.forEach(function (text, index) {
            var highlight = "".concat(bind, "==").concat(first + index);
            groupLabel.push(text);
            groupLogic.push(highlight);
          });
        } else if (type === "space") {
          var count = entry.count;

          for (var i = 0; i < count; i++) {
            groupLabel.push("");
            groupLogic.push("");
          }
        }
      });
      logic.push(groupLogic);
      label.push(groupLabel);
    });
    return {
      logic: logic,
      label: label
    };
  };

  const OPERATORS$1 = "!%&*()-+=|/<>";
  const isNumericString = string => {
    return /^-?\d+$/.test(string);
  };
  const extractStringContainedInOutermostBraces = source => {
    if (typeof source !== "string") {
      return "";
    }

    let leftOfBraces;
    let rightOfBraces;
    let insideBraces;
    let count;
    let firstBrace;
    let i;
    let c;
    firstBrace = source.indexOf("(");
    i = 1 + firstBrace;
    leftOfBraces = source.substr(0, firstBrace);
    count = 1;

    while (count > 0 && i < source.length) {
      c = source.substr(i, 1);

      if (c == "(") {
        count++;
      }

      if (c == ")") {
        count--;
      }

      i++;
    }

    if (i < source.length) {
      rightOfBraces = source.substr(i);
    } else {
      rightOfBraces = "";
    }

    insideBraces = source.substr(1 + firstBrace, i - 1 - (1 + firstBrace));
    return [leftOfBraces, insideBraces, rightOfBraces];
  };
  const scanForInstanceOf = ({
    source,
    array
  } = {}) => {
    if (typeof source !== "string" || !Array.isArray(array)) {
      return -1;
    }

    for (let i = 0; i < array.length; i++) {
      if (source.indexOf(array[i]) !== -1) {
        return i;
      }
    }

    return -1;
  };
  const extractTermsAroundPivot = ({
    source,
    pivot
  }) => {
    let leftTerm;
    let rightTerm;
    let leftOfPivot;
    let rightOfPivot;
    let beforeLeftTerm;
    let afterRightTerm;
    let c;
    let i;
    const pivotLocation = source.indexOf(pivot);
    leftOfPivot = source.substr(0, pivotLocation);
    rightOfPivot = source.substr(pivotLocation + pivot.length); // left term

    leftTerm = "";
    i = leftOfPivot.length - 1;
    c = leftOfPivot.substr(i, 1);

    while (i > 0 && OPERATORS$1.indexOf(c) === -1) {
      i--;
      c = leftOfPivot.substr(i, 1);
    }

    if (OPERATORS$1.indexOf(c) !== -1) {
      leftTerm = leftOfPivot.substr(i + 1);
      beforeLeftTerm = leftOfPivot.substr(0, i + 1);
    } else {
      leftTerm = leftOfPivot.substr(i);
      beforeLeftTerm = leftOfPivot.substr(0, i);
    } // right term


    rightTerm = "";

    if (rightOfPivot.length > 0) {
      i = 0;
      c = rightOfPivot.substr(i, 1);

      while (i < rightOfPivot.length && OPERATORS$1.indexOf(c) === -1) {
        i++;

        if (i < rightOfPivot.length) {
          c = rightOfPivot.substr(i, 1);
        }
      }
    }

    if (i < rightOfPivot.length) {
      rightTerm = rightOfPivot.substr(0, i);
      afterRightTerm = rightOfPivot.substr(i);
    } else {
      rightTerm = rightOfPivot;
      afterRightTerm = "";
    }

    return [beforeLeftTerm, leftTerm, rightTerm, afterRightTerm];
  };
  const contains = ({
    source,
    instance
  } = {}) => {
    if (typeof source !== "string") {
      return false;
    }

    return source.indexOf(instance) !== -1;
  };
  const containsBraces = source => {
    return contains({
      source,
      instance: "("
    }) > 0 || contains({
      source,
      instance: ")"
    }) > 0;
  };

  var OPERATORS = {
    EQUALITY: ["===", "!==", "==", "!=", ">=", "<=", ">", "<"],
    MATH: ["%", "*", "/", "+", "-"],
    BOOLEAN: ["&&", "||"],
    CONVERSION: ["-", "!"]
  }; // ____________________________________________________________________________________________________ term

  var term = function term(source, props) {
    var terms;
    var parsing = false;
    var result;
    parsing = true;

    while (parsing) {
      // parse brackets
      if (containsBraces(source)) {
        terms = extractStringContainedInOutermostBraces(source);
        var termResult = term(terms[1], props);
        source = "".concat(terms[0]).concat(termResult).concat(terms[2]);
      } else {
        // parse math operators
        result = scanForInstanceOf({
          source: source,
          array: OPERATORS.MATH
        });

        if (result !== -1) {
          terms = extractTermsAroundPivot({
            source: source,
            pivot: OPERATORS.MATH[result]
          });
          var operationResult = performOperation({
            termOne: terms[1],
            termTwo: terms[2],
            operator: OPERATORS.MATH[result],
            props: props
          });
          source = "".concat(terms[0]).concat(operationResult).concat(terms[3]);
        } else {
          // parse equality operators
          result = scanForInstanceOf({
            source: source,
            array: OPERATORS.EQUALITY
          });

          if (result !== -1) {
            terms = extractTermsAroundPivot({
              source: source,
              pivot: OPERATORS.EQUALITY[result]
            });

            var _operationResult = performOperation({
              termOne: terms[1],
              termTwo: terms[2],
              operator: OPERATORS.EQUALITY[result],
              props: props
            });

            source = "".concat(terms[0]).concat(_operationResult).concat(terms[3]);
          } else {
            // parse boolean operators
            result = scanForInstanceOf({
              source: source,
              array: OPERATORS.BOOLEAN
            });

            if (result !== -1) {
              terms = extractTermsAroundPivot({
                source: source,
                pivot: OPERATORS.BOOLEAN[result]
              });

              var _operationResult2 = performOperation({
                termOne: terms[1],
                termTwo: terms[2],
                operator: OPERATORS.BOOLEAN[result],
                props: props
              });

              source = "".concat(terms[0]).concat(_operationResult2).concat(terms[3]);
            } else {
              parsing = false;
            }
          }
        }
      }
    }

    return processTerm(source, props);
  }; // ____________________________________________________________________________________________________ Process
  // check for var names, - and !

  var processTerm = function processTerm() {
    var source = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : "";
    var props = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
    var result;
    var isString = typeof source === "string";

    if (isString) {
      source = source.trim();
    }

    var isNumeric = isNumericString(source);

    if (isString && source.startsWith("-")) {
      result = processTerm(source.substr(1), props);
      return 0 - result;
    } else if (isString && source.startsWith("!")) {
      result = processTerm(source.substr(1), props); // invert result

      return !result;
    } else if (isNumeric) {
      return parseInt(source);
    } else if (source === "else") {
      // 'else' is used as a convenient phrase for the xml, logically it's the equivalent of 'true'
      return true;
    } else if (source === "false") {
      return false;
    } else if (source === "true") {
      return true;
    } // return from props


    if (props[source] !== undefined) {
      return processTerm(props[source], props);
    }

    return source;
  }; // ____________________________________________________________________________________________________ operation

  var performOperation = function performOperation() {
    var _ref = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {},
        termOne = _ref.termOne,
        termTwo = _ref.termTwo,
        operator = _ref.operator,
        props = _ref.props;

    // replace variable names where appropriate
    var a = processTerm(termOne, props);
    var b = processTerm(termTwo, props);
    var result = 0;

    if (operator === "*") {
      result = a * b;
    } else if (operator === "/") {
      result = a / b;
    } else if (operator === "+") {
      result = a + b;
    } else if (operator === "-") {
      result = a - b;
    } else if (operator === "%") {
      result = a % b;
    } else if (operator === "&&") {
      result = a && b;
    } else if (operator === "||") {
      result = a || b;
    } else if (operator === "!=") {
      result = a !== b;
    } else if (operator === "==") {
      result = a === b;
    } else if (operator === ">") {
      result = a > b;
    } else if (operator === "<") {
      result = a < b;
    } else if (operator === ">=") {
      result = a >= b;
    } else if (operator === "<=") {
      result = a <= b;
    }

    return result;
  };

  function styleInject(css, ref) {
    if (ref === void 0) ref = {};
    var insertAt = ref.insertAt;

    if (!css || typeof document === 'undefined') {
      return;
    }

    var head = document.head || document.getElementsByTagName('head')[0];
    var style = document.createElement('style');
    style.type = 'text/css';

    if (insertAt === 'top') {
      if (head.firstChild) {
        head.insertBefore(style, head.firstChild);
      } else {
        head.appendChild(style);
      }
    } else {
      head.appendChild(style);
    }

    if (style.styleSheet) {
      style.styleSheet.cssText = css;
    } else {
      style.appendChild(document.createTextNode(css));
    }
  }

  var css_248z = ".WordClock-module_container__t8Dqz {\n  width: 100%;\n  height: 100%; }\n\n.WordClock-module_words__3W2_V {\n  color: #999;\n  font-weight: bold;\n  transition: opacity 0.15s;\n  display: flex;\n  flex-direction: row;\n  flex-wrap: wrap;\n  height: 100%; }\n\n.WordClock-module_wordsResizing__3qRAw {\n  opacity: 0;\n  visibility: hidden;\n  height: auto; }\n\n.WordClock-module_word__1ziNY {\n  display: flex;\n  margin-right: 0.25em;\n  transition: color 0.15s; }\n\n.WordClock-module_wordHighlighted__3ZWlC {\n  color: #cc0000; }\n";
  var styles = {"container":"WordClock-module_container__t8Dqz word-clock","words":"WordClock-module_words__3W2_V words","wordsResizing":"WordClock-module_wordsResizing__3qRAw WordClock-module_words__3W2_V words resizing","word":"WordClock-module_word__1ziNY word","wordHighlighted":"WordClock-module_wordHighlighted__3ZWlC WordClock-module_word__1ziNY word word-highlighted"};
  styleInject(css_248z);

  function ownKeys(object, enumerableOnly) { var keys = Object.keys(object); if (Object.getOwnPropertySymbols) { var symbols = Object.getOwnPropertySymbols(object); if (enumerableOnly) { symbols = symbols.filter(function (sym) { return Object.getOwnPropertyDescriptor(object, sym).enumerable; }); } keys.push.apply(keys, symbols); } return keys; }

  function _objectSpread(target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i] != null ? arguments[i] : {}; if (i % 2) { ownKeys(Object(source), true).forEach(function (key) { _defineProperty(target, key, source[key]); }); } else if (Object.getOwnPropertyDescriptors) { Object.defineProperties(target, Object.getOwnPropertyDescriptors(source)); } else { ownKeys(Object(source)).forEach(function (key) { Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key)); }); } } return target; }

  var WordClockInner = function WordClockInner(_ref) {
    var logic = _ref.logic,
        label = _ref.label,
        timeProps = _ref.timeProps;
        _ref.fontSize;
    return label.map(function (labelGroup, labelIndex) {
      var logicGroup = logic[labelIndex];
      var highlighted;
      var hasPreviousHighlight = false; // only allow a single highlight per group

      return labelGroup.map(function (label, labelGroupIndex) {
        highlighted = false;

        if (!hasPreviousHighlight) {
          var _logic = logicGroup[labelGroupIndex];
          highlighted = term(_logic, timeProps);

          if (highlighted) {
            hasPreviousHighlight = true;
          }
        }

        if (!label.length) {
          return null;
        }

        return /*#__PURE__*/React__namespace.createElement("div", {
          className: highlighted ? styles.wordHighlighted : styles.word,
          key: "".concat(labelIndex, "-").concat(labelGroupIndex)
        }, label);
      });
    });
  };

  var FIT = {
    UNKNOWN: "UNKNOWN",
    SMALL: "SMALL",
    OK: "OK",
    LARGE: "LARGE"
  };
  var minimumFontSizeAdjustment = 0.01;
  var sizeStateDefault = {
    fontSize: 12,
    lineHeight: 1,
    previousFontSize: 12,
    fontSizeLow: 1,
    fontSizeHigh: 256,
    previousFit: FIT.UNKNOWN
  };

  var WordClock = function WordClock(_ref2) {
    var words = _ref2.words;
    var containerRef = React__namespace.useRef(null);
    var innerRef = React__namespace.useRef(null);
    var ro = React__namespace.useRef(null);

    var _React$useState = React__namespace.useState([]),
        _React$useState2 = _slicedToArray(_React$useState, 2),
        logic = _React$useState2[0],
        setLogic = _React$useState2[1];

    var _React$useState3 = React__namespace.useState([]),
        _React$useState4 = _slicedToArray(_React$useState3, 2),
        label = _React$useState4[0],
        setLabel = _React$useState4[1];

    var _React$useState5 = React__namespace.useState({
      width: 0,
      height: 0
    }),
        _React$useState6 = _slicedToArray(_React$useState5, 2),
        targetSize = _React$useState6[0],
        setTargetSize = _React$useState6[1];

    var _React$useState7 = React__namespace.useState(_objectSpread({}, sizeStateDefault)),
        _React$useState8 = _slicedToArray(_React$useState7, 2),
        sizeState = _React$useState8[0],
        setSizeState = _React$useState8[1];

    var timeProps = useTimeProps();
    var updateResizeObserver = React__namespace.useCallback(function () {
      if (ro.current) {
        if (containerRef.current) {
          ro.current.unobserve(containerRef.current);
        }
      } else {
        ro.current = new index(function (entries) {
          var currentRefEntry = entries.find(function (_ref3) {
            var target = _ref3.target;
            return target === containerRef.current;
          });

          if (currentRefEntry) {
            var _currentRefEntry$cont = currentRefEntry.contentRect,
                width = _currentRefEntry$cont.width,
                height = _currentRefEntry$cont.height;
            setTargetSize({
              width: width,
              height: height
            });
          }
        });
      }

      if (containerRef.current) {
        ro.current.observe(containerRef.current);
      }

      return function () {
        ro.current.disconnect();
        ro.current = null;
      };
    }, [setTargetSize]);
    var setContainerRef = React__namespace.useCallback(function (ref) {
      if (ref && ref !== containerRef.current) {
        containerRef.current = ref;
        updateResizeObserver();
      }
    }, [updateResizeObserver]);
    React__namespace.useEffect(function () {
      if (!containerRef.current || !innerRef.current || targetSize.width === 0) {
        return;
      }

      var boundingClientRect = innerRef.current.getBoundingClientRect();
      var height = boundingClientRect.height;
      var nextFontSize = 0.5 * (sizeState.fontSize + sizeState.fontSizeLow);
      var fontSizeDifference = Math.abs(sizeState.fontSize - nextFontSize);

      if (sizeState.previousTargetSize) {
        // component resized - start resizing again
        if (sizeState.previousTargetSize.width !== targetSize.width || sizeState.previousTargetSize.height !== targetSize.height) {
          setSizeState(_objectSpread(_objectSpread({}, sizeStateDefault), {}, {
            previousTargetSize: targetSize
          }));
          return;
        }
      }

      if (sizeState.previousFit === FIT.OK) ; else if (height < targetSize.height) {
        // currently FIT.SMALL
        // increase size
        setSizeState(_objectSpread(_objectSpread({}, sizeState), {}, {
          fontSize: 0.5 * (sizeState.fontSize + sizeState.fontSizeHigh),
          previousFontSize: sizeState.fontSize,
          fontSizeLow: sizeState.fontSize,
          previousFit: FIT.SMALL,
          previousTargetSize: targetSize,
          previousHeight: height
        }));
      } else {
        // currently FIT.LARGE
        if (sizeState.previousFit === FIT.SMALL && fontSizeDifference <= minimumFontSizeAdjustment) {
          // use previous size
          setSizeState(_objectSpread(_objectSpread({}, sizeState), {}, {
            fontSize: sizeState.previousFontSize,
            previousFit: FIT.OK,
            previousTargetSize: targetSize
          }));
        } else {
          // decrease size
          setSizeState(_objectSpread(_objectSpread({}, sizeState), {}, {
            fontSize: nextFontSize,
            previousFontSize: sizeState.fontSize,
            fontSizeHigh: sizeState.fontSize,
            previousFit: FIT.LARGE,
            previousTargetSize: targetSize,
            previousHeight: height
          }));
        }
      }
    }, [sizeState, targetSize, targetSize.height, targetSize.width]);
    var style = React__namespace.useMemo(function () {
      return {
        fontSize: sizeState.fontSize,
        lineHeight: sizeState.lineHeight
      };
    }, [sizeState.fontSize, sizeState.lineHeight]);
    React__namespace.useEffect(function () {
      if (!words) {
        return;
      }

      var parsed = parseJson(words);
      setLogic(parsed.logic);
      setLabel(parsed.label); // start resizing

      setSizeState(_objectSpread({}, sizeStateDefault));
    }, [words]);
    var isResizing = sizeState.previousFit !== FIT.OK;
    return /*#__PURE__*/React__namespace.createElement(React__namespace.Fragment, null, /*#__PURE__*/React__namespace.createElement("div", {
      ref: setContainerRef,
      className: styles.container
    }, /*#__PURE__*/React__namespace.createElement("div", {
      ref: innerRef,
      className: isResizing ? styles.wordsResizing : styles.words,
      style: style
    }, /*#__PURE__*/React__namespace.createElement(WordClockInner, {
      logic: logic,
      label: label,
      timeProps: timeProps
    }))));
  };

  exports.WordClock = WordClock;

  Object.defineProperty(exports, '__esModule', { value: true });

})));
//# sourceMappingURL=index.js.map
