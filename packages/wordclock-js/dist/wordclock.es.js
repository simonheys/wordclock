import { jsx as m, Fragment as N } from "react/jsx-runtime";
import * as v from "react";
import { useState as x, useEffect as _, useRef as W, useCallback as I } from "react";
import { isString as g, isArray as j } from "lodash";
const M = (e = /* @__PURE__ */ new Date()) => {
  const t = e.getDay();
  let r = t - 1;
  for (; r < 0; )
    r += 7;
  const i = e.getDate(), n = e.getMonth(), s = e.getHours() % 12, o = e.getHours(), c = e.getMinutes(), u = e.getSeconds();
  return {
    day: t,
    daystartingmonday: r,
    date: i,
    month: n,
    hour: s,
    twentyfourhour: o,
    minute: c,
    second: u
  };
}, G = () => {
  const [e, t] = x(M());
  return _(() => {
    const r = setInterval(() => {
      t(M());
    }, 1e3);
    return () => clearInterval(r);
  }, []), e;
}, q = ({ groups: e }) => {
  const t = [], r = [];
  return e.forEach((i) => {
    const n = [], s = [];
    i.forEach((o) => {
      const c = o.type;
      if (c === "item")
        o.items.forEach((a) => {
          const f = a.highlight, l = a.text || "";
          n.push(l), s.push(f);
        });
      else if (c === "sequence") {
        const u = o.bind, a = o.first;
        o.text.forEach((l, d) => {
          const F = `${u}==${a + d}`;
          n.push(l), s.push(F);
        });
      } else if (c === "space") {
        const u = o.count;
        for (let a = 0; a < u; a++)
          n.push(""), s.push("");
      }
    }), r.push(s), t.push(n);
  }), { logic: r, label: t };
}, V = "_container_1nb32_1 word-clock", Y = "_words_1nb32_7 words", Q = "_word_1nb32_7 word", U = "_wordHighlighted_1nb32_26 _word_1nb32_7 word word-highlighted", w = {
  container: V,
  words: Y,
  word: Q,
  wordHighlighted: U
}, R = "!%&*()-+=|/<>", J = (e) => /^-?\d+$/.test(e), K = (e) => {
  if (!g(e))
    return "";
  let t, r, i, n, s, o, c;
  for (s = e.indexOf("("), o = 1 + s, t = e.substr(0, s), n = 1; n > 0 && o < e.length; )
    c = e.substr(o, 1), c === "(" && n++, c === ")" && n--, o++;
  return o < e.length ? r = e.substr(o) : r = "", i = e.substr(1 + s, o - 1 - (1 + s)), [t, i, r];
}, T = ({
  source: e,
  array: t
} = {}) => {
  if (!g(e) || !j(t))
    return -1;
  for (let r = 0; r < t.length; r++)
    if (e.indexOf(t[r]) !== -1)
      return r;
  return -1;
}, z = ({
  source: e,
  pivot: t
}) => {
  let r, i, n, s, o, c, u, a;
  const f = e.indexOf(t);
  for (n = e.substr(0, f), s = e.substr(f + t.length), r = "", a = n.length - 1, u = n.substr(a, 1); a > 0 && R.indexOf(u) === -1; )
    a--, u = n.substr(a, 1);
  if (R.indexOf(u) !== -1 ? (r = n.substr(a + 1), o = n.substr(0, a + 1)) : (r = n.substr(a), o = n.substr(0, a)), i = "", s.length > 0)
    for (a = 0, u = s.substr(a, 1); a < s.length && R.indexOf(u) === -1; )
      a++, a < s.length && (u = s.substr(a, 1));
  return a < s.length ? (i = s.substr(0, a), c = s.substr(a)) : (i = s, c = ""), [o, r, i, c];
}, k = ({
  source: e,
  instance: t
} = {}) => !g(e) || !g(t) ? !1 : e.indexOf(t) !== -1, X = (e) => k({ source: e, instance: "(" }) || k({ source: e, instance: ")" }), h = {
  EQUALITY: ["===", "!==", "==", "!=", ">=", "<=", ">", "<"],
  MATH: ["%", "*", "/", "+", "-"],
  BOOLEAN: ["&&", "||"],
  CONVERSION: ["-", "!"]
}, $ = (e, t) => {
  let r, i = !1, n;
  for (i = !0; i; )
    if (X(e)) {
      r = K(e);
      const s = $(r[1], t);
      e = `${r[0]}${s}${r[2]}`;
    } else if (n = T({
      source: e,
      array: h.MATH
    }), n !== -1) {
      r = z({
        source: e,
        pivot: h.MATH[n]
      });
      const s = A({
        termOne: r[1],
        termTwo: r[2],
        operator: h.MATH[n],
        props: t
      });
      e = `${r[0]}${s}${r[3]}`;
    } else if (n = T({
      source: e,
      array: h.EQUALITY
    }), n !== -1) {
      r = z({
        source: e,
        pivot: h.EQUALITY[n]
      });
      const s = A({
        termOne: r[1],
        termTwo: r[2],
        operator: h.EQUALITY[n],
        props: t
      });
      e = `${r[0]}${s}${r[3]}`;
    } else if (n = T({
      source: e,
      array: h.BOOLEAN
    }), n !== -1) {
      r = z({
        source: e,
        pivot: h.BOOLEAN[n]
      });
      const s = A({
        termOne: r[1],
        termTwo: r[2],
        operator: h.BOOLEAN[n],
        props: t
      });
      e = `${r[0]}${s}${r[3]}`;
    } else
      i = !1;
  return b(e, t);
}, b = (e = "", t = {}) => {
  let r;
  const i = g(e);
  i && (e = e.trim());
  const n = J(e);
  return i && e.startsWith("-") ? (r = b(e.substr(1), t), 0 - r) : i && e.startsWith("!") ? (r = b(e.substr(1), t), !r) : n ? parseInt(e) : e === "else" ? !0 : e === "false" ? !1 : e === "true" ? !0 : t[e] !== void 0 ? b(t[e], t) : e;
}, A = ({
  termOne: e,
  termTwo: t,
  operator: r,
  props: i
} = {}) => {
  let n = b(e, i), s = b(t, i), o = 0;
  switch (r) {
    case "*":
      o = n * s;
      break;
    case "/":
      o = n / s;
      break;
    case "+":
      o = n + s;
      break;
    case "-":
      o = n - s;
      break;
    case "%":
      o = n % s;
      break;
    case "&&":
      o = n && s;
      break;
    case "||":
      o = n || s;
      break;
    case "!=":
    case "!==":
      o = n !== s;
      break;
    case "==":
    case "===":
      o = n === s;
      break;
    case ">":
      o = n > s;
      break;
    case "<":
      o = n < s;
      break;
    case ">=":
      o = n >= s;
      break;
    case "<=":
      o = n <= s;
      break;
  }
  return o;
}, Z = ({
  logic: e,
  label: t,
  timeProps: r
}) => /* @__PURE__ */ m(N, { children: t.map((i, n) => {
  const s = e[n];
  let o = !1, c = !1;
  return i.map((u, a) => {
    if (c = !1, !o) {
      const f = s[a];
      c = $(f, r), c && (o = !0);
    }
    return u.length ? /* @__PURE__ */ m(
      "div",
      {
        className: c ? w.wordHighlighted : w.word,
        children: u
      },
      `${n}-${a}`
    ) : null;
  });
}) });
var C = function() {
  if (typeof Map < "u")
    return Map;
  function e(t, r) {
    var i = -1;
    return t.some(function(n, s) {
      return n[0] === r ? (i = s, !0) : !1;
    }), i;
  }
  return (
    /** @class */
    function() {
      function t() {
        this.__entries__ = [];
      }
      return Object.defineProperty(t.prototype, "size", {
        /**
         * @returns {boolean}
         */
        get: function() {
          return this.__entries__.length;
        },
        enumerable: !0,
        configurable: !0
      }), t.prototype.get = function(r) {
        var i = e(this.__entries__, r), n = this.__entries__[i];
        return n && n[1];
      }, t.prototype.set = function(r, i) {
        var n = e(this.__entries__, r);
        ~n ? this.__entries__[n][1] = i : this.__entries__.push([r, i]);
      }, t.prototype.delete = function(r) {
        var i = this.__entries__, n = e(i, r);
        ~n && i.splice(n, 1);
      }, t.prototype.has = function(r) {
        return !!~e(this.__entries__, r);
      }, t.prototype.clear = function() {
        this.__entries__.splice(0);
      }, t.prototype.forEach = function(r, i) {
        i === void 0 && (i = null);
        for (var n = 0, s = this.__entries__; n < s.length; n++) {
          var o = s[n];
          r.call(i, o[1], o[0]);
        }
      }, t;
    }()
  );
}(), S = typeof window < "u" && typeof document < "u" && window.document === document, y = function() {
  return typeof global < "u" && global.Math === Math ? global : typeof self < "u" && self.Math === Math ? self : typeof window < "u" && window.Math === Math ? window : Function("return this")();
}(), ee = function() {
  return typeof requestAnimationFrame == "function" ? requestAnimationFrame.bind(y) : function(e) {
    return setTimeout(function() {
      return e(Date.now());
    }, 1e3 / 60);
  };
}(), te = 2;
function re(e, t) {
  var r = !1, i = !1, n = 0;
  function s() {
    r && (r = !1, e()), i && c();
  }
  function o() {
    ee(s);
  }
  function c() {
    var u = Date.now();
    if (r) {
      if (u - n < te)
        return;
      i = !0;
    } else
      r = !0, i = !1, setTimeout(o, t);
    n = u;
  }
  return c;
}
var ne = 20, ie = ["top", "right", "bottom", "left", "width", "height", "size", "weight"], se = typeof MutationObserver < "u", oe = (
  /** @class */
  function() {
    function e() {
      this.connected_ = !1, this.mutationEventsAdded_ = !1, this.mutationsObserver_ = null, this.observers_ = [], this.onTransitionEnd_ = this.onTransitionEnd_.bind(this), this.refresh = re(this.refresh.bind(this), ne);
    }
    return e.prototype.addObserver = function(t) {
      ~this.observers_.indexOf(t) || this.observers_.push(t), this.connected_ || this.connect_();
    }, e.prototype.removeObserver = function(t) {
      var r = this.observers_, i = r.indexOf(t);
      ~i && r.splice(i, 1), !r.length && this.connected_ && this.disconnect_();
    }, e.prototype.refresh = function() {
      var t = this.updateObservers_();
      t && this.refresh();
    }, e.prototype.updateObservers_ = function() {
      var t = this.observers_.filter(function(r) {
        return r.gatherActive(), r.hasActive();
      });
      return t.forEach(function(r) {
        return r.broadcastActive();
      }), t.length > 0;
    }, e.prototype.connect_ = function() {
      !S || this.connected_ || (document.addEventListener("transitionend", this.onTransitionEnd_), window.addEventListener("resize", this.refresh), se ? (this.mutationsObserver_ = new MutationObserver(this.refresh), this.mutationsObserver_.observe(document, {
        attributes: !0,
        childList: !0,
        characterData: !0,
        subtree: !0
      })) : (document.addEventListener("DOMSubtreeModified", this.refresh), this.mutationEventsAdded_ = !0), this.connected_ = !0);
    }, e.prototype.disconnect_ = function() {
      !S || !this.connected_ || (document.removeEventListener("transitionend", this.onTransitionEnd_), window.removeEventListener("resize", this.refresh), this.mutationsObserver_ && this.mutationsObserver_.disconnect(), this.mutationEventsAdded_ && document.removeEventListener("DOMSubtreeModified", this.refresh), this.mutationsObserver_ = null, this.mutationEventsAdded_ = !1, this.connected_ = !1);
    }, e.prototype.onTransitionEnd_ = function(t) {
      var r = t.propertyName, i = r === void 0 ? "" : r, n = ie.some(function(s) {
        return !!~i.indexOf(s);
      });
      n && this.refresh();
    }, e.getInstance = function() {
      return this.instance_ || (this.instance_ = new e()), this.instance_;
    }, e.instance_ = null, e;
  }()
), H = function(e, t) {
  for (var r = 0, i = Object.keys(t); r < i.length; r++) {
    var n = i[r];
    Object.defineProperty(e, n, {
      value: t[n],
      enumerable: !1,
      writable: !1,
      configurable: !0
    });
  }
  return e;
}, p = function(e) {
  var t = e && e.ownerDocument && e.ownerDocument.defaultView;
  return t || y;
}, P = E(0, 0, 0, 0);
function O(e) {
  return parseFloat(e) || 0;
}
function L(e) {
  for (var t = [], r = 1; r < arguments.length; r++)
    t[r - 1] = arguments[r];
  return t.reduce(function(i, n) {
    var s = e["border-" + n + "-width"];
    return i + O(s);
  }, 0);
}
function ae(e) {
  for (var t = ["top", "right", "bottom", "left"], r = {}, i = 0, n = t; i < n.length; i++) {
    var s = n[i], o = e["padding-" + s];
    r[s] = O(o);
  }
  return r;
}
function ce(e) {
  var t = e.getBBox();
  return E(0, 0, t.width, t.height);
}
function ue(e) {
  var t = e.clientWidth, r = e.clientHeight;
  if (!t && !r)
    return P;
  var i = p(e).getComputedStyle(e), n = ae(i), s = n.left + n.right, o = n.top + n.bottom, c = O(i.width), u = O(i.height);
  if (i.boxSizing === "border-box" && (Math.round(c + s) !== t && (c -= L(i, "left", "right") + s), Math.round(u + o) !== r && (u -= L(i, "top", "bottom") + o)), !he(e)) {
    var a = Math.round(c + s) - t, f = Math.round(u + o) - r;
    Math.abs(a) !== 1 && (c -= a), Math.abs(f) !== 1 && (u -= f);
  }
  return E(n.left, n.top, c, u);
}
var fe = function() {
  return typeof SVGGraphicsElement < "u" ? function(e) {
    return e instanceof p(e).SVGGraphicsElement;
  } : function(e) {
    return e instanceof p(e).SVGElement && typeof e.getBBox == "function";
  };
}();
function he(e) {
  return e === p(e).document.documentElement;
}
function le(e) {
  return S ? fe(e) ? ce(e) : ue(e) : P;
}
function de(e) {
  var t = e.x, r = e.y, i = e.width, n = e.height, s = typeof DOMRectReadOnly < "u" ? DOMRectReadOnly : Object, o = Object.create(s.prototype);
  return H(o, {
    x: t,
    y: r,
    width: i,
    height: n,
    top: r,
    right: t + i,
    bottom: n + r,
    left: t
  }), o;
}
function E(e, t, r, i) {
  return { x: e, y: t, width: r, height: i };
}
var ve = (
  /** @class */
  function() {
    function e(t) {
      this.broadcastWidth = 0, this.broadcastHeight = 0, this.contentRect_ = E(0, 0, 0, 0), this.target = t;
    }
    return e.prototype.isActive = function() {
      var t = le(this.target);
      return this.contentRect_ = t, t.width !== this.broadcastWidth || t.height !== this.broadcastHeight;
    }, e.prototype.broadcastRect = function() {
      var t = this.contentRect_;
      return this.broadcastWidth = t.width, this.broadcastHeight = t.height, t;
    }, e;
  }()
), be = (
  /** @class */
  function() {
    function e(t, r) {
      var i = de(r);
      H(this, { target: t, contentRect: i });
    }
    return e;
  }()
), pe = (
  /** @class */
  function() {
    function e(t, r, i) {
      if (this.activeObservations_ = [], this.observations_ = new C(), typeof t != "function")
        throw new TypeError("The callback provided as parameter 1 is not a function.");
      this.callback_ = t, this.controller_ = r, this.callbackCtx_ = i;
    }
    return e.prototype.observe = function(t) {
      if (!arguments.length)
        throw new TypeError("1 argument required, but only 0 present.");
      if (!(typeof Element > "u" || !(Element instanceof Object))) {
        if (!(t instanceof p(t).Element))
          throw new TypeError('parameter 1 is not of type "Element".');
        var r = this.observations_;
        r.has(t) || (r.set(t, new ve(t)), this.controller_.addObserver(this), this.controller_.refresh());
      }
    }, e.prototype.unobserve = function(t) {
      if (!arguments.length)
        throw new TypeError("1 argument required, but only 0 present.");
      if (!(typeof Element > "u" || !(Element instanceof Object))) {
        if (!(t instanceof p(t).Element))
          throw new TypeError('parameter 1 is not of type "Element".');
        var r = this.observations_;
        r.has(t) && (r.delete(t), r.size || this.controller_.removeObserver(this));
      }
    }, e.prototype.disconnect = function() {
      this.clearActive(), this.observations_.clear(), this.controller_.removeObserver(this);
    }, e.prototype.gatherActive = function() {
      var t = this;
      this.clearActive(), this.observations_.forEach(function(r) {
        r.isActive() && t.activeObservations_.push(r);
      });
    }, e.prototype.broadcastActive = function() {
      if (this.hasActive()) {
        var t = this.callbackCtx_, r = this.activeObservations_.map(function(i) {
          return new be(i.target, i.broadcastRect());
        });
        this.callback_.call(t, r, t), this.clearActive();
      }
    }, e.prototype.clearActive = function() {
      this.activeObservations_.splice(0);
    }, e.prototype.hasActive = function() {
      return this.activeObservations_.length > 0;
    }, e;
  }()
), B = typeof WeakMap < "u" ? /* @__PURE__ */ new WeakMap() : new C(), D = (
  /** @class */
  function() {
    function e(t) {
      if (!(this instanceof e))
        throw new TypeError("Cannot call a class as a function.");
      if (!arguments.length)
        throw new TypeError("1 argument required, but only 0 present.");
      var r = oe.getInstance(), i = new pe(t, r, this);
      B.set(this, i);
    }
    return e;
  }()
);
[
  "observe",
  "unobserve",
  "disconnect"
].forEach(function(e) {
  D.prototype[e] = function() {
    var t;
    return (t = B.get(this))[e].apply(t, arguments);
  };
});
var me = function() {
  return typeof y.ResizeObserver < "u" ? y.ResizeObserver : D;
}();
const ge = () => {
  const e = v.useRef(null), t = v.useRef(null), [r, i] = v.useState({
    width: 0,
    height: 0
  }), n = v.useCallback(() => {
    t.current && (e.current && t.current.unobserve(e.current), t.current.disconnect(), t.current = null);
  }, []), s = v.useCallback(() => {
    t.current && n(), e.current && (t.current = new me((c) => {
      const u = c.find(
        ({ target: a }) => a === e.current
      );
      if (u) {
        const { width: a, height: f } = u.contentRect;
        i({ width: a, height: f });
      }
    }), t.current.observe(e.current));
  }, [n]);
  return { ref: v.useCallback(
    (c) => {
      n(), e.current = c, s();
    },
    [s, n]
  ), useRef: e, size: r };
}, _e = 1e-4, we = () => {
  const { ref: e, size: t } = ge(), r = W(null), i = I(() => {
    if (!r.current || !t.height)
      return;
    let n = 1, s = 256, o = !1, c = -1, u = -1, a = !1, f = !1, l = !1, d;
    for (r.current.style.height = "auto"; !o && Math.abs(n - s) > _e; )
      n !== c && (r.current.style.fontSize = `${n}px`, a = r.current.scrollHeight < t.height, c = n), s !== u && (r.current.style.fontSize = `${s}px`, f = r.current.scrollHeight < t.height, u = s), a && !f ? (d = (n + s) * 0.5, r.current.style.fontSize = `${d}px`, l = r.current.scrollHeight < t.height, l ? n = d : s = d) : o = !0;
    r.current.style.fontSize = `${n}px`, r.current.style.removeProperty("height");
  }, [t]);
  return _(() => {
    i();
  }, [i, t]), {
    resizeRef: r,
    containerRef: e,
    resize: i
  };
}, Re = ({ words: e }) => {
  const [t, r] = x([]), [i, n] = x([]), s = G(), { resizeRef: o, containerRef: c, resize: u } = we();
  return _(() => {
    if (!e)
      return;
    const a = q(e);
    r(a.logic), n(a.label);
  }, [e]), _(() => {
    u();
  }, [t, u]), /* @__PURE__ */ m("div", { ref: c, className: w.container, children: /* @__PURE__ */ m("div", { ref: o, className: w.words, children: /* @__PURE__ */ m(Z, { logic: t, label: i, timeProps: s }) }) });
};
export {
  Re as WordClock
};
