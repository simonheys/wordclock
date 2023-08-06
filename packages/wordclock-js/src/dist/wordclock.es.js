import { jsx as w, Fragment as q } from "react/jsx-runtime";
import * as p from "react";
import {
  useState as z,
  useEffect as H,
  useRef as V,
  useMemo as K,
} from "react";
import { isString as y, isArray as U } from "lodash";
var N = (function () {
    if (typeof Map < "u") return Map;
    function e(n, t) {
      var i = -1;
      return (
        n.some(function (r, s) {
          return r[0] === t ? ((i = s), !0) : !1;
        }),
        i
      );
    }
    return (
      /** @class */
      (function () {
        function n() {
          this.__entries__ = [];
        }
        return (
          Object.defineProperty(n.prototype, "size", {
            /**
             * @returns {boolean}
             */
            get: function () {
              return this.__entries__.length;
            },
            enumerable: !0,
            configurable: !0,
          }),
          (n.prototype.get = function (t) {
            var i = e(this.__entries__, t),
              r = this.__entries__[i];
            return r && r[1];
          }),
          (n.prototype.set = function (t, i) {
            var r = e(this.__entries__, t);
            ~r ? (this.__entries__[r][1] = i) : this.__entries__.push([t, i]);
          }),
          (n.prototype.delete = function (t) {
            var i = this.__entries__,
              r = e(i, t);
            ~r && i.splice(r, 1);
          }),
          (n.prototype.has = function (t) {
            return !!~e(this.__entries__, t);
          }),
          (n.prototype.clear = function () {
            this.__entries__.splice(0);
          }),
          (n.prototype.forEach = function (t, i) {
            i === void 0 && (i = null);
            for (var r = 0, s = this.__entries__; r < s.length; r++) {
              var o = s[r];
              t.call(i, o[1], o[0]);
            }
          }),
          n
        );
      })()
    );
  })(),
  C =
    typeof window < "u" &&
    typeof document < "u" &&
    window.document === document,
  S = (function () {
    return typeof global < "u" && global.Math === Math
      ? global
      : typeof self < "u" && self.Math === Math
      ? self
      : typeof window < "u" && window.Math === Math
      ? window
      : Function("return this")();
  })(),
  Y = (function () {
    return typeof requestAnimationFrame == "function"
      ? requestAnimationFrame.bind(S)
      : function (e) {
          return setTimeout(function () {
            return e(Date.now());
          }, 1e3 / 60);
        };
  })(),
  Q = 2;
function J(e, n) {
  var t = !1,
    i = !1,
    r = 0;
  function s() {
    t && ((t = !1), e()), i && c();
  }
  function o() {
    Y(s);
  }
  function c() {
    var f = Date.now();
    if (t) {
      if (f - r < Q) return;
      i = !0;
    } else (t = !0), (i = !1), setTimeout(o, n);
    r = f;
  }
  return c;
}
var X = 20,
  Z = ["top", "right", "bottom", "left", "width", "height", "size", "weight"],
  ee = typeof MutationObserver < "u",
  te =
    /** @class */
    (function () {
      function e() {
        (this.connected_ = !1),
          (this.mutationEventsAdded_ = !1),
          (this.mutationsObserver_ = null),
          (this.observers_ = []),
          (this.onTransitionEnd_ = this.onTransitionEnd_.bind(this)),
          (this.refresh = J(this.refresh.bind(this), X));
      }
      return (
        (e.prototype.addObserver = function (n) {
          ~this.observers_.indexOf(n) || this.observers_.push(n),
            this.connected_ || this.connect_();
        }),
        (e.prototype.removeObserver = function (n) {
          var t = this.observers_,
            i = t.indexOf(n);
          ~i && t.splice(i, 1),
            !t.length && this.connected_ && this.disconnect_();
        }),
        (e.prototype.refresh = function () {
          var n = this.updateObservers_();
          n && this.refresh();
        }),
        (e.prototype.updateObservers_ = function () {
          var n = this.observers_.filter(function (t) {
            return t.gatherActive(), t.hasActive();
          });
          return (
            n.forEach(function (t) {
              return t.broadcastActive();
            }),
            n.length > 0
          );
        }),
        (e.prototype.connect_ = function () {
          !C ||
            this.connected_ ||
            (document.addEventListener("transitionend", this.onTransitionEnd_),
            window.addEventListener("resize", this.refresh),
            ee
              ? ((this.mutationsObserver_ = new MutationObserver(this.refresh)),
                this.mutationsObserver_.observe(document, {
                  attributes: !0,
                  childList: !0,
                  characterData: !0,
                  subtree: !0,
                }))
              : (document.addEventListener("DOMSubtreeModified", this.refresh),
                (this.mutationEventsAdded_ = !0)),
            (this.connected_ = !0));
        }),
        (e.prototype.disconnect_ = function () {
          !C ||
            !this.connected_ ||
            (document.removeEventListener(
              "transitionend",
              this.onTransitionEnd_,
            ),
            window.removeEventListener("resize", this.refresh),
            this.mutationsObserver_ && this.mutationsObserver_.disconnect(),
            this.mutationEventsAdded_ &&
              document.removeEventListener("DOMSubtreeModified", this.refresh),
            (this.mutationsObserver_ = null),
            (this.mutationEventsAdded_ = !1),
            (this.connected_ = !1));
        }),
        (e.prototype.onTransitionEnd_ = function (n) {
          var t = n.propertyName,
            i = t === void 0 ? "" : t,
            r = Z.some(function (s) {
              return !!~i.indexOf(s);
            });
          r && this.refresh();
        }),
        (e.getInstance = function () {
          return this.instance_ || (this.instance_ = new e()), this.instance_;
        }),
        (e.instance_ = null),
        e
      );
    })(),
  W = function (e, n) {
    for (var t = 0, i = Object.keys(n); t < i.length; t++) {
      var r = i[t];
      Object.defineProperty(e, r, {
        value: n[r],
        enumerable: !1,
        writable: !1,
        configurable: !0,
      });
    }
    return e;
  },
  b = function (e) {
    var n = e && e.ownerDocument && e.ownerDocument.defaultView;
    return n || S;
  },
  k = R(0, 0, 0, 0);
function E(e) {
  return parseFloat(e) || 0;
}
function $(e) {
  for (var n = [], t = 1; t < arguments.length; t++) n[t - 1] = arguments[t];
  return n.reduce(function (i, r) {
    var s = e["border-" + r + "-width"];
    return i + E(s);
  }, 0);
}
function ne(e) {
  for (
    var n = ["top", "right", "bottom", "left"], t = {}, i = 0, r = n;
    i < r.length;
    i++
  ) {
    var s = r[i],
      o = e["padding-" + s];
    t[s] = E(o);
  }
  return t;
}
function re(e) {
  var n = e.getBBox();
  return R(0, 0, n.width, n.height);
}
function ie(e) {
  var n = e.clientWidth,
    t = e.clientHeight;
  if (!n && !t) return k;
  var i = b(e).getComputedStyle(e),
    r = ne(i),
    s = r.left + r.right,
    o = r.top + r.bottom,
    c = E(i.width),
    f = E(i.height);
  if (
    (i.boxSizing === "border-box" &&
      (Math.round(c + s) !== n && (c -= $(i, "left", "right") + s),
      Math.round(f + o) !== t && (f -= $(i, "top", "bottom") + o)),
    !oe(e))
  ) {
    var u = Math.round(c + s) - n,
      a = Math.round(f + o) - t;
    Math.abs(u) !== 1 && (c -= u), Math.abs(a) !== 1 && (f -= a);
  }
  return R(r.left, r.top, c, f);
}
var se = (function () {
  return typeof SVGGraphicsElement < "u"
    ? function (e) {
        return e instanceof b(e).SVGGraphicsElement;
      }
    : function (e) {
        return e instanceof b(e).SVGElement && typeof e.getBBox == "function";
      };
})();
function oe(e) {
  return e === b(e).document.documentElement;
}
function fe(e) {
  return C ? (se(e) ? re(e) : ie(e)) : k;
}
function ue(e) {
  var n = e.x,
    t = e.y,
    i = e.width,
    r = e.height,
    s = typeof DOMRectReadOnly < "u" ? DOMRectReadOnly : Object,
    o = Object.create(s.prototype);
  return (
    W(o, {
      x: n,
      y: t,
      width: i,
      height: r,
      top: t,
      right: n + i,
      bottom: r + t,
      left: n,
    }),
    o
  );
}
function R(e, n, t, i) {
  return { x: e, y: n, width: t, height: i };
}
var ce =
    /** @class */
    (function () {
      function e(n) {
        (this.broadcastWidth = 0),
          (this.broadcastHeight = 0),
          (this.contentRect_ = R(0, 0, 0, 0)),
          (this.target = n);
      }
      return (
        (e.prototype.isActive = function () {
          var n = fe(this.target);
          return (
            (this.contentRect_ = n),
            n.width !== this.broadcastWidth || n.height !== this.broadcastHeight
          );
        }),
        (e.prototype.broadcastRect = function () {
          var n = this.contentRect_;
          return (
            (this.broadcastWidth = n.width),
            (this.broadcastHeight = n.height),
            n
          );
        }),
        e
      );
    })(),
  ae =
    /** @class */
    (function () {
      function e(n, t) {
        var i = ue(t);
        W(this, { target: n, contentRect: i });
      }
      return e;
    })(),
  he =
    /** @class */
    (function () {
      function e(n, t, i) {
        if (
          ((this.activeObservations_ = []),
          (this.observations_ = new N()),
          typeof n != "function")
        )
          throw new TypeError(
            "The callback provided as parameter 1 is not a function.",
          );
        (this.callback_ = n), (this.controller_ = t), (this.callbackCtx_ = i);
      }
      return (
        (e.prototype.observe = function (n) {
          if (!arguments.length)
            throw new TypeError("1 argument required, but only 0 present.");
          if (!(typeof Element > "u" || !(Element instanceof Object))) {
            if (!(n instanceof b(n).Element))
              throw new TypeError('parameter 1 is not of type "Element".');
            var t = this.observations_;
            t.has(n) ||
              (t.set(n, new ce(n)),
              this.controller_.addObserver(this),
              this.controller_.refresh());
          }
        }),
        (e.prototype.unobserve = function (n) {
          if (!arguments.length)
            throw new TypeError("1 argument required, but only 0 present.");
          if (!(typeof Element > "u" || !(Element instanceof Object))) {
            if (!(n instanceof b(n).Element))
              throw new TypeError('parameter 1 is not of type "Element".');
            var t = this.observations_;
            t.has(n) &&
              (t.delete(n), t.size || this.controller_.removeObserver(this));
          }
        }),
        (e.prototype.disconnect = function () {
          this.clearActive(),
            this.observations_.clear(),
            this.controller_.removeObserver(this);
        }),
        (e.prototype.gatherActive = function () {
          var n = this;
          this.clearActive(),
            this.observations_.forEach(function (t) {
              t.isActive() && n.activeObservations_.push(t);
            });
        }),
        (e.prototype.broadcastActive = function () {
          if (this.hasActive()) {
            var n = this.callbackCtx_,
              t = this.activeObservations_.map(function (i) {
                return new ae(i.target, i.broadcastRect());
              });
            this.callback_.call(n, t, n), this.clearActive();
          }
        }),
        (e.prototype.clearActive = function () {
          this.activeObservations_.splice(0);
        }),
        (e.prototype.hasActive = function () {
          return this.activeObservations_.length > 0;
        }),
        e
      );
    })(),
  G = typeof WeakMap < "u" ? /* @__PURE__ */ new WeakMap() : new N(),
  I =
    /** @class */
    (function () {
      function e(n) {
        if (!(this instanceof e))
          throw new TypeError("Cannot call a class as a function.");
        if (!arguments.length)
          throw new TypeError("1 argument required, but only 0 present.");
        var t = te.getInstance(),
          i = new he(n, t, this);
        G.set(this, i);
      }
      return e;
    })();
["observe", "unobserve", "disconnect"].forEach(function (e) {
  I.prototype[e] = function () {
    var n;
    return (n = G.get(this))[e].apply(n, arguments);
  };
});
var le = (function () {
  return typeof S.ResizeObserver < "u" ? S.ResizeObserver : I;
})();
const de = () => {
    const e = p.useRef(null),
      n = p.useRef(null),
      [t, i] = p.useState({
        width: 0,
        height: 0,
      }),
      r = p.useCallback(() => {
        n.current &&
          (e.current && n.current.unobserve(e.current),
          n.current.disconnect(),
          (n.current = null));
      }, []),
      s = p.useCallback(() => {
        n.current && r(),
          e.current &&
            ((n.current = new le((c) => {
              const f = c.find(({ target: u }) => u === e.current);
              if (f) {
                const { width: u, height: a } = f.contentRect;
                i({ width: u, height: a });
              }
            })),
            n.current.observe(e.current));
      }, [r]);
    return {
      ref: p.useCallback(
        (c) => {
          r(), (e.current = c), s();
        },
        [s, r],
      ),
      useRef: e,
      size: t,
    };
  },
  D = (e = /* @__PURE__ */ new Date()) => {
    const n = e.getDay();
    let t = n - 1;
    for (; t < 0; ) t += 7;
    const i = e.getDate(),
      r = e.getMonth(),
      s = e.getHours() % 12,
      o = e.getHours(),
      c = e.getMinutes(),
      f = e.getSeconds();
    return {
      day: n,
      daystartingmonday: t,
      date: i,
      month: r,
      hour: s,
      twentyfourhour: o,
      minute: c,
      second: f,
    };
  },
  ve = () => {
    const [e, n] = z(D());
    return (
      H(() => {
        const t = setInterval(() => {
          n(D());
        }, 1e3);
        return () => clearInterval(t);
      }, []),
      e
    );
  },
  A = "!%&*()-+=|/<>",
  pe = (e) => /^-?\d+$/.test(e),
  ge = (e) => {
    if (!y(e)) return "";
    let n, t, i, r, s, o, c;
    for (
      s = e.indexOf("("), o = 1 + s, n = e.substr(0, s), r = 1;
      r > 0 && o < e.length;

    )
      (c = e.substr(o, 1)), c === "(" && r++, c === ")" && r--, o++;
    return (
      o < e.length ? (t = e.substr(o)) : (t = ""),
      (i = e.substr(1 + s, o - 1 - (1 + s))),
      [n, i, t]
    );
  },
  x = ({ source: e, array: n } = {}) => {
    if (!y(e) || !U(n)) return -1;
    for (let t = 0; t < n.length; t++) if (e.indexOf(n[t]) !== -1) return t;
    return -1;
  },
  M = ({ source: e, pivot: n }) => {
    let t, i, r, s, o, c, f, u;
    const a = e.indexOf(n);
    for (
      r = e.substr(0, a),
        s = e.substr(a + n.length),
        t = "",
        u = r.length - 1,
        f = r.substr(u, 1);
      u > 0 && A.indexOf(f) === -1;

    )
      u--, (f = r.substr(u, 1));
    if (
      (A.indexOf(f) !== -1
        ? ((t = r.substr(u + 1)), (o = r.substr(0, u + 1)))
        : ((t = r.substr(u)), (o = r.substr(0, u))),
      (i = ""),
      s.length > 0)
    )
      for (u = 0, f = s.substr(u, 1); u < s.length && A.indexOf(f) === -1; )
        u++, u < s.length && (f = s.substr(u, 1));
    return (
      u < s.length
        ? ((i = s.substr(0, u)), (c = s.substr(u)))
        : ((i = s), (c = "")),
      [o, t, i, c]
    );
  },
  B = ({ source: e, instance: n } = {}) =>
    !y(e) || !y(n) ? !1 : e.indexOf(n) !== -1,
  be = (e) =>
    B({ source: e, instance: "(" }) || B({ source: e, instance: ")" }),
  h = {
    EQUALITY: ["===", "!==", "==", "!=", ">=", "<=", ">", "<"],
    MATH: ["%", "*", "/", "+", "-"],
    BOOLEAN: ["&&", "||"],
    CONVERSION: ["-", "!"],
  },
  j = (e, n) => {
    let t,
      i = !1,
      r;
    for (i = !0; i; )
      if (be(e)) {
        t = ge(e);
        const s = j(t[1], n);
        e = `${t[0]}${s}${t[2]}`;
      } else if (
        ((r = x({
          source: e,
          array: h.MATH,
        })),
        r !== -1)
      ) {
        t = M({
          source: e,
          pivot: h.MATH[r],
        });
        const s = L({
          termOne: t[1],
          termTwo: t[2],
          operator: h.MATH[r],
          props: n,
        });
        e = `${t[0]}${s}${t[3]}`;
      } else if (
        ((r = x({
          source: e,
          array: h.EQUALITY,
        })),
        r !== -1)
      ) {
        t = M({
          source: e,
          pivot: h.EQUALITY[r],
        });
        const s = L({
          termOne: t[1],
          termTwo: t[2],
          operator: h.EQUALITY[r],
          props: n,
        });
        e = `${t[0]}${s}${t[3]}`;
      } else if (
        ((r = x({
          source: e,
          array: h.BOOLEAN,
        })),
        r !== -1)
      ) {
        t = M({
          source: e,
          pivot: h.BOOLEAN[r],
        });
        const s = L({
          termOne: t[1],
          termTwo: t[2],
          operator: h.BOOLEAN[r],
          props: n,
        });
        e = `${t[0]}${s}${t[3]}`;
      } else i = !1;
    return g(e, n);
  },
  g = (e = "", n = {}) => {
    let t;
    const i = y(e);
    i && (e = e.trim());
    const r = pe(e);
    return i && e.startsWith("-")
      ? ((t = g(e.substr(1), n)), 0 - t)
      : i && e.startsWith("!")
      ? ((t = g(e.substr(1), n)), !t)
      : r
      ? parseInt(e)
      : e === "else"
      ? !0
      : e === "false"
      ? !1
      : e === "true"
      ? !0
      : n[e] !== void 0
      ? g(n[e], n)
      : e;
  },
  L = ({ termOne: e, termTwo: n, operator: t, props: i } = {}) => {
    let r = g(e, i),
      s = g(n, i),
      o = 0;
    return (
      t === "*"
        ? (o = r * s)
        : t === "/"
        ? (o = r / s)
        : t === "+"
        ? (o = r + s)
        : t === "-"
        ? (o = r - s)
        : t === "%"
        ? (o = r % s)
        : t === "&&"
        ? (o = r && s)
        : t === "||"
        ? (o = r || s)
        : t === "!="
        ? (o = r !== s)
        : t === "=="
        ? (o = r === s)
        : t === ">"
        ? (o = r > s)
        : t === "<"
        ? (o = r < s)
        : t === ">="
        ? (o = r >= s)
        : t === "<=" && (o = r <= s),
      o
    );
  },
  me = ({ groups: e }) => {
    const n = [],
      t = [];
    return (
      e.forEach((i) => {
        const r = [],
          s = [];
        i.forEach((o) => {
          const c = o.type;
          if (c === "item")
            o.items.forEach((u) => {
              const a = u.highlight,
                m = u.text || "";
              r.push(m), s.push(a);
            });
          else if (c === "sequence") {
            const f = o.bind,
              u = o.first;
            o.text.forEach((m, T) => {
              const l = `${f}==${u + T}`;
              r.push(m), s.push(l);
            });
          } else if (c === "space") {
            const f = o.count;
            for (let u = 0; u < f; u++) r.push(""), s.push("");
          }
        }),
          t.push(s),
          n.push(r);
      }),
      { logic: t, label: n }
    );
  },
  _e = "_container_1drai_1 word-clock",
  we = "_words_1drai_7 words",
  Oe = "_wordsResizing_1drai_19 _words_1drai_7 words resizing",
  ye = "_word_1drai_7 word",
  ze = "_wordHighlighted_1drai_34 _word_1drai_7 word word-highlighted",
  O = {
    container: _e,
    words: we,
    wordsResizing: Oe,
    word: ye,
    wordHighlighted: ze,
  },
  Se = ({ logic: e, label: n, timeProps: t }) =>
    /* @__PURE__ */ w(q, {
      children: n.map((i, r) => {
        const s = e[r];
        let o,
          c = !1;
        return i.map((f, u) => {
          if (((o = !1), !c)) {
            const a = s[u];
            (o = j(a, t)), o && (c = !0);
          }
          return f.length
            ? /* @__PURE__ */ w(
                "div",
                {
                  className: o ? O.wordHighlighted : O.word,
                  children: f,
                },
                `${r}-${u}`,
              )
            : null;
        });
      }),
    }),
  Ee = 1e-5,
  F = {
    fontSize: 12,
    previousFontSize: 12,
    fontSizeLow: 1,
    fontSizeHigh: 256,
    previousFit: "UNKNOWN",
    /* UNKNOWN */
  },
  xe = ({ words: e }) => {
    const n = V(null),
      { ref: t, size: i } = de(),
      [r, s] = z([]),
      [o, c] = z([]),
      [f, u] = z({
        ...F,
      }),
      a = ve();
    H(() => {
      var P;
      if (!i.width || !i.height) return;
      if (
        f.previousTargetSize &&
        (f.previousTargetSize.width !== i.width ||
          f.previousTargetSize.height !== i.height)
      ) {
        u({ ...F, previousTargetSize: i });
        return;
      }
      const l = ((P = n.current) == null ? void 0 : P.scrollHeight) ?? 0;
      if (f.previousFit !== "OK")
        if (l === i.height)
          u((d) => ({
            ...d,
            previousFit: "OK",
            previousTargetSize: i,
          }));
        else if (l < i.height) {
          const d = 0.5 * (f.fontSize + f.fontSizeHigh);
          u((_) => ({
            ..._,
            fontSize: d,
            previousFontSize: _.fontSize,
            fontSizeLow: _.fontSize,
            previousFit: "SMALL",
            previousTargetSize: i,
          }));
        } else {
          const d = 0.5 * (f.fontSize + f.fontSizeLow),
            _ = Math.abs(f.fontSize - d);
          f.previousFit === "SMALL" && _ <= Ee
            ? u((v) => ({
                ...v,
                fontSize: v.previousFontSize,
                previousFit: "OK",
                previousTargetSize: i,
              }))
            : u((v) => ({
                ...v,
                fontSize: d,
                previousFontSize: v.fontSize,
                fontSizeHigh: v.fontSize,
                previousFit: "LARGE",
                previousTargetSize: i,
              }));
        }
    }, [
      f.fontSize,
      f.fontSizeHigh,
      f.fontSizeLow,
      f.previousFit,
      f.previousTargetSize,
      i,
    ]);
    const m = K(
      () => ({
        fontSize: f.fontSize,
      }),
      [f.fontSize],
    );
    H(() => {
      if (!e) return;
      const l = me(e);
      s(l.logic), c(l.label), u({ ...F });
    }, [e]);
    const T = f.previousFit !== "OK";
    return /* @__PURE__ */ w("div", {
      ref: t,
      className: O.container,
      children: /* @__PURE__ */ w("div", {
        ref: n,
        className: T ? O.wordsResizing : O.words,
        style: m,
        children: /* @__PURE__ */ w(Se, { logic: r, label: o, timeProps: a }),
      }),
    });
  };
export { xe as WordClock };
