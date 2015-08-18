# cssfmt.el
An emacs interface for [cssfmt](https://github.com/morishitter/cssfmt), gofmt inspired css code formatter.

# Installation

Install cssfmt

```
npm install -g cssfmt
```

then add to your init.el

```lisp
(add-hook 'after-save-hook 'cssfmt-after-save)
```

# Example


```css
      @media screen and (    min-width :699px)
 {.foo    +       .bar,.hoge{
    font-size   :12px      !   important   ;  ~       .fuga     {
      padding      : 10px       5px;
   color:green;
 >p

 {
        line-height             : 1.5          ;
      }}}
     }


.class,           #id
 {     color       : blue;

  border        :solid  #ddd                1px}
```

yields

```css
@media screen and (min-width: 699px) {
  .foo + .bar,
  .hoge {
    font-size: 12px !important;

    ~ .fuga {
      padding: 10px 5px;
      color: green;

      > p {
        line-height: 1.5;
      }
    }
  }
}


.class,
#id {
  color: blue;
  border: 1px solid #ddd;
}

```

