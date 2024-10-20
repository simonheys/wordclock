import * as v from "react";
import { createContext as F, useContext as N, useState as z, useEffect as y, useRef as j, useCallback as G } from "react";
import { jsx as p, Fragment as I } from "react/jsx-runtime";
import { isString as g, isArray as q } from "lodash-es";
const k = F(null), V = () => {
  const e = N(k);
  if (!e)
    throw new Error("useWordClock must be used within a WordClockProvider");
  return e;
}, Y = k.Provider, S = (e = /* @__PURE__ */ new Date()) => {
  const t = e.getDay();
  let r = t - 1;
  for (; r < 0; )
    r += 7;
  const i = e.getDate(), n = e.getMonth(), s = e.getHours() % 12, o = e.getHours(), u = e.getMinutes(), c = e.getSeconds();
  return {
    day: t,
    daystartingmonday: r,
    date: i,
    month: n,
    hour: s,
    twentyfourhour: o,
    minute: u,
    second: c
  };
}, Q = () => {
  const [e, t] = z(S());
  return y(() => {
    const r = setInterval(() => {
      t(S());
    }, 1e3);
    return () => clearInterval(r);
  }, []), e;
}, U = ({ groups: e }) => {
  const t = [], r = [];
  return e.forEach((i) => {
    const n = [], s = [];
    i.forEach((o) => {
      const u = o.type;
      if (u === "item")
        o.items.forEach((a) => {
          const f = a.highlight, l = a.text || "";
          n.push(l), s.push(f);
        });
      else if (u === "sequence") {
        const c = o.bind, a = o.first;
        o.text.forEach((l, d) => {
          const D = `${c}==${a + d}`;
          n.push(l), s.push(D);
        });
      } else if (u === "space") {
        const c = o.count;
        for (let a = 0; a < c; a++)
          n.push(""), s.push("");
      }
    }), r.push(s), t.push(n);
  }), { logic: r, label: t };
};
var L = function() {
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
}(), A = typeof window < "u" && typeof document < "u" && window.document === document, _ = function() {
  return typeof global < "u" && global.Math === Math ? global : typeof self < "u" && self.Math === Math ? self : typeof window < "u" && window.Math === Math ? window : Function("return this")();
}(), J = function() {
  return typeof requestAnimationFrame == "function" ? requestAnimationFrame.bind(_) : function(e) {
    return setTimeout(function() {
      return e(Date.now());
    }, 1e3 / 60);
  };
}(), K = 2;
function X(e, t) {
  var r = !1, i = !1, n = 0;
  function s() {
    r && (r = !1, e()), i && u();
  }
  function o() {
    J(s);
  }
  function u() {
    var c = Date.now();
    if (r) {
      if (c - n < K)
        return;
      i = !0;
    } else
      r = !0, i = !1, setTimeout(o, t);
    n = c;
  }
  return u;
}
var Z = 20, ee = ["top", "right", "bottom", "left", "width", "height", "size", "weight"], te = typeof MutationObserver < "u", re = (
  /** @class */
  function() {
    function e() {
      this.connected_ = !1, this.mutationEventsAdded_ = !1, this.mutationsObserver_ = null, this.observers_ = [], this.onTransitionEnd_ = this.onTransitionEnd_.bind(this), this.refresh = X(this.refresh.bind(this), Z);
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
      !A || this.connected_ || (document.addEventListener("transitionend", this.onTransitionEnd_), window.addEventListener("resize", this.refresh), te ? (this.mutationsObserver_ = new MutationObserver(this.refresh), this.mutationsObserver_.observe(document, {
        attributes: !0,
        childList: !0,
        characterData: !0,
        subtree: !0
      })) : (document.addEventListener("DOMSubtreeModified", this.refresh), this.mutationEventsAdded_ = !0), this.connected_ = !0);
    }, e.prototype.disconnect_ = function() {
      !A || !this.connected_ || (document.removeEventListener("transitionend", this.onTransitionEnd_), window.removeEventListener("resize", this.refresh), this.mutationsObserver_ && this.mutationsObserver_.disconnect(), this.mutationEventsAdded_ && document.removeEventListener("DOMSubtreeModified", this.refresh), this.mutationsObserver_ = null, this.mutationEventsAdded_ = !1, this.connected_ = !1);
    }, e.prototype.onTransitionEnd_ = function(t) {
      var r = t.propertyName, i = r === void 0 ? "" : r, n = ee.some(function(s) {
        return !!~i.indexOf(s);
      });
      n && this.refresh();
    }, e.getInstance = function() {
      return this.instance_ || (this.instance_ = new e()), this.instance_;
    }, e.instance_ = null, e;
  }()
), P = function(e, t) {
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
}, m = function(e) {
  var t = e && e.ownerDocument && e.ownerDocument.defaultView;
  return t || _;
}, $ = w(0, 0, 0, 0);
function O(e) {
  return parseFloat(e) || 0;
}
function C(e) {
  for (var t = [], r = 1; r < arguments.length; r++)
    t[r - 1] = arguments[r];
  return t.reduce(function(i, n) {
    var s = e["border-" + n + "-width"];
    return i + O(s);
  }, 0);
}
function ne(e) {
  for (var t = ["top", "right", "bottom", "left"], r = {}, i = 0, n = t; i < n.length; i++) {
    var s = n[i], o = e["padding-" + s];
    r[s] = O(o);
  }
  return r;
}
function ie(e) {
  var t = e.getBBox();
  return w(0, 0, t.width, t.height);
}
function se(e) {
  var t = e.clientWidth, r = e.clientHeight;
  if (!t && !r)
    return $;
  var i = m(e).getComputedStyle(e), n = ne(i), s = n.left + n.right, o = n.top + n.bottom, u = O(i.width), c = O(i.height);
  if (i.boxSizing === "border-box" && (Math.round(u + s) !== t && (u -= C(i, "left", "right") + s), Math.round(c + o) !== r && (c -= C(i, "top", "bottom") + o)), !ae(e)) {
    var a = Math.round(u + s) - t, f = Math.round(c + o) - r;
    Math.abs(a) !== 1 && (u -= a), Math.abs(f) !== 1 && (c -= f);
  }
  return w(n.left, n.top, u, c);
}
var oe = /* @__PURE__ */ function() {
  return typeof SVGGraphicsElement < "u" ? function(e) {
    return e instanceof m(e).SVGGraphicsElement;
  } : function(e) {
    return e instanceof m(e).SVGElement && typeof e.getBBox == "function";
  };
}();
function ae(e) {
  return e === m(e).document.documentElement;
}
function ce(e) {
  return A ? oe(e) ? ie(e) : se(e) : $;
}
function ue(e) {
  var t = e.x, r = e.y, i = e.width, n = e.height, s = typeof DOMRectReadOnly < "u" ? DOMRectReadOnly : Object, o = Object.create(s.prototype);
  return P(o, {
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
function w(e, t, r, i) {
  return { x: e, y: t, width: r, height: i };
}
var fe = (
  /** @class */
  function() {
    function e(t) {
      this.broadcastWidth = 0, this.broadcastHeight = 0, this.contentRect_ = w(0, 0, 0, 0), this.target = t;
    }
    return e.prototype.isActive = function() {
      var t = ce(this.target);
      return this.contentRect_ = t, t.width !== this.broadcastWidth || t.height !== this.broadcastHeight;
    }, e.prototype.broadcastRect = function() {
      var t = this.contentRect_;
      return this.broadcastWidth = t.width, this.broadcastHeight = t.height, t;
    }, e;
  }()
), le = (
  /** @class */
  /* @__PURE__ */ function() {
    function e(t, r) {
      var i = ue(r);
      P(this, { target: t, contentRect: i });
    }
    return e;
  }()
), he = (
  /** @class */
  function() {
    function e(t, r, i) {
      if (this.activeObservations_ = [], this.observations_ = new L(), typeof t != "function")
        throw new TypeError("The callback provided as parameter 1 is not a function.");
      this.callback_ = t, this.controller_ = r, this.callbackCtx_ = i;
    }
    return e.prototype.observe = function(t) {
      if (!arguments.length)
        throw new TypeError("1 argument required, but only 0 present.");
      if (!(typeof Element > "u" || !(Element instanceof Object))) {
        if (!(t instanceof m(t).Element))
          throw new TypeError('parameter 1 is not of type "Element".');
        var r = this.observations_;
        r.has(t) || (r.set(t, new fe(t)), this.controller_.addObserver(this), this.controller_.refresh());
      }
    }, e.prototype.unobserve = function(t) {
      if (!arguments.length)
        throw new TypeError("1 argument required, but only 0 present.");
      if (!(typeof Element > "u" || !(Element instanceof Object))) {
        if (!(t instanceof m(t).Element))
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
          return new le(i.target, i.broadcastRect());
        });
        this.callback_.call(t, r, t), this.clearActive();
      }
    }, e.prototype.clearActive = function() {
      this.activeObservations_.splice(0);
    }, e.prototype.hasActive = function() {
      return this.activeObservations_.length > 0;
    }, e;
  }()
), W = typeof WeakMap < "u" ? /* @__PURE__ */ new WeakMap() : new L(), H = (
  /** @class */
  /* @__PURE__ */ function() {
    function e(t) {
      if (!(this instanceof e))
        throw new TypeError("Cannot call a class as a function.");
      if (!arguments.length)
        throw new TypeError("1 argument required, but only 0 present.");
      var r = re.getInstance(), i = new he(t, r, this);
      W.set(this, i);
    }
    return e;
  }()
);
[
  "observe",
  "unobserve",
  "disconnect"
].forEach(function(e) {
  H.prototype[e] = function() {
    var t;
    return (t = W.get(this))[e].apply(t, arguments);
  };
});
var de = function() {
  return typeof _.ResizeObserver < "u" ? _.ResizeObserver : H;
}();
const ve = () => {
  const e = v.useRef(null), t = v.useRef(null), [r, i] = v.useState({
    width: 0,
    height: 0
  }), n = v.useCallback(() => {
    t.current && (e.current && t.current.unobserve(e.current), t.current.disconnect(), t.current = null);
  }, []), s = v.useCallback(() => {
    t.current && n(), e.current && (t.current = new de((u) => {
      const c = u.find(
        ({ target: a }) => a === e.current
      );
      if (c) {
        const { width: a, height: f } = c.contentRect;
        i({ width: a, height: f });
      }
    }), t.current.observe(e.current));
  }, [n]);
  return { ref: v.useCallback(
    (u) => {
      n(), e.current = u, s();
    },
    [s, n]
  ), useRef: e, size: r };
}, pe = 1e-4, be = () => {
  const { ref: e, size: t } = ve(), r = j(null), i = G(() => {
    if (!r.current || !t.height)
      return;
    let n = 1, s = 256, o = !1, u = -1, c = -1, a = !1, f = !1, l = !1, d;
    for (r.current.style.height = "auto"; !o && Math.abs(n - s) > pe; )
      n !== u && (r.current.style.fontSize = `${n}px`, a = r.current.scrollHeight < t.height, u = n), s !== c && (r.current.style.fontSize = `${s}px`, f = r.current.scrollHeight < t.height, c = s), a && !f ? (d = (n + s) * 0.5, r.current.style.fontSize = `${d}px`, l = r.current.scrollHeight < t.height, l ? n = d : s = d) : o = !0;
    r.current.style.fontSize = `${n}px`, r.current.style.removeProperty("height");
  }, [t]);
  return y(() => {
    i();
  }, [i, t]), {
    resizeRef: r,
    containerRef: e,
    resize: i
  };
}, me = {
  width: "100%",
  height: "100%"
}, ge = {
  display: "flex",
  flexDirection: "row",
  flexWrap: "wrap",
  height: "100%"
}, ze = ({ words: e, children: t, ...r }) => {
  const [i, n] = z([]), [s, o] = z([]), u = Q(), { resizeRef: c, containerRef: a, resize: f } = be();
  return y(() => {
    if (!e)
      return;
    const l = U(e);
    n(l.logic), o(l.label);
  }, [e]), y(() => {
    f();
  }, [i, f]), /* @__PURE__ */ p("div", { ref: a, style: me, children: /* @__PURE__ */ p("div", { ref: c, style: ge, ...r, children: /* @__PURE__ */ p(Y, { value: { logic: i, label: s, timeProps: u }, children: t }) }) });
}, E = "!%&*()-+=|/<>", ye = (e) => /^-?\d+$/.test(e), _e = (e) => {
  if (!g(e))
    return "";
  let t, r, i, n, s, o, u;
  for (s = e.indexOf("("), o = 1 + s, t = e.substr(0, s), n = 1; n > 0 && o < e.length; )
    u = e.substr(o, 1), u === "(" && n++, u === ")" && n--, o++;
  return o < e.length ? r = e.substr(o) : r = "", i = e.substr(1 + s, o - 1 - (1 + s)), [t, i, r];
}, R = ({
  source: e,
  array: t
} = {}) => {
  if (!g(e) || !q(t))
    return -1;
  for (let r = 0; r < t.length; r++)
    if (e.indexOf(t[r]) !== -1)
      return r;
  return -1;
}, x = ({
  source: e,
  pivot: t
}) => {
  let r, i, n, s, o, u, c, a;
  const f = e.indexOf(t);
  for (n = e.substr(0, f), s = e.substr(f + t.length), r = "", a = n.length - 1, c = n.substr(a, 1); a > 0 && E.indexOf(c) === -1; )
    a--, c = n.substr(a, 1);
  if (E.indexOf(c) !== -1 ? (r = n.substr(a + 1), o = n.substr(0, a + 1)) : (r = n.substr(a), o = n.substr(0, a)), i = "", s.length > 0)
    for (a = 0, c = s.substr(a, 1); a < s.length && E.indexOf(c) === -1; )
      a++, a < s.length && (c = s.substr(a, 1));
  return a < s.length ? (i = s.substr(0, a), u = s.substr(a)) : (i = s, u = ""), [o, r, i, u];
}, M = ({
  source: e,
  instance: t
} = {}) => !g(e) || !g(t) ? !1 : e.indexOf(t) !== -1, Oe = (e) => M({ source: e, instance: "(" }) || M({ source: e, instance: ")" }), h = {
  EQUALITY: ["===", "!==", "==", "!=", ">=", "<=", ">", "<"],
  MATH: ["%", "*", "/", "+", "-"],
  BOOLEAN: ["&&", "||"],
  CONVERSION: ["-", "!"]
}, B = (e, t) => {
  let r, i = !1, n;
  for (i = !0; i; )
    if (Oe(e)) {
      r = _e(e);
      const s = B(r[1], t);
      e = `${r[0]}${s}${r[2]}`;
    } else if (n = R({
      source: e,
      array: h.MATH
    }), n !== -1) {
      r = x({
        source: e,
        pivot: h.MATH[n]
      });
      const s = T({
        termOne: r[1],
        termTwo: r[2],
        operator: h.MATH[n],
        props: t
      });
      e = `${r[0]}${s}${r[3]}`;
    } else if (n = R({
      source: e,
      array: h.EQUALITY
    }), n !== -1) {
      r = x({
        source: e,
        pivot: h.EQUALITY[n]
      });
      const s = T({
        termOne: r[1],
        termTwo: r[2],
        operator: h.EQUALITY[n],
        props: t
      });
      e = `${r[0]}${s}${r[3]}`;
    } else if (n = R({
      source: e,
      array: h.BOOLEAN
    }), n !== -1) {
      r = x({
        source: e,
        pivot: h.BOOLEAN[n]
      });
      const s = T({
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
  const n = ye(e);
  return i && e.startsWith("-") ? (r = b(e.substr(1), t), 0 - r) : i && e.startsWith("!") ? (r = b(e.substr(1), t), !r) : n ? parseInt(e) : e === "else" ? !0 : e === "false" ? !1 : e === "true" ? !0 : t[e] !== void 0 ? b(t[e], t) : e;
}, T = ({
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
}, we = {
  marginRight: "0.2em",
  transition: "color 0.15s"
}, Ee = ({
  highlighted: e,
  ...t
}) => /* @__PURE__ */ p(
  "div",
  {
    style: {
      ...we,
      color: e ? "#ff0000" : "inherit"
    },
    ...t
  }
), Ae = ({
  wordComponent: e = Ee
}) => {
  const { logic: t, label: r, timeProps: i } = V();
  return /* @__PURE__ */ p(I, { children: r.map((n, s) => {
    const o = t[s];
    let u = !1, c = !1;
    return n.map((a, f) => {
      if (c = !1, !u) {
        const l = o[f];
        c = B(l, i), c && (u = !0);
      }
      return a.length ? /* @__PURE__ */ p(
        e,
        {
          highlighted: c,
          children: a
        },
        `${s}-${f}`
      ) : null;
    });
  }) });
};
export {
  ze as WordClock,
  Ae as WordClockContent,
  Y as WordClockProvider,
  Ee as WordClockWord,
  V as useWordClock
};
