# Contributing and Markdown Style Guide

* [Kubecost Docs](markdown.md#docs)
  * [Titles](markdown.md#docs-titles)
  * [Links](markdown.md#docs-links)
  * [Images](markdown.md#docs-images)
  * [Metadata](markdown.md#docs-metdata)
  * [Categories and Sections](markdown.md#docs-cs)
  * [Create a New Doc](markdown.md#docs-create)
  * [Build and Deploy](markdown.md#docs-bd)
  * [Update Existing Doc](markdown.md#docs-update)
* [Overview](markdown.md#overview)
  * [Inline HTML](markdown.md#html)
  * [Automatic Escaping for Special Characters](markdown.md#autoescape)
  * [HTML details tag](markdown.md#details)
* [Block Elements](markdown.md#block)
  * [Paragraphs and Line Breaks](markdown.md#p)
  * [Headers](markdown.md#header)
  * [Blockquotes](markdown.md#blockquote)
  * [Lists](markdown.md#list)
  * [Code Blocks](markdown.md#precode)
  * [Horizontal Rules](markdown.md#hr)
* [Span Elements](markdown.md#span)
  * [Links](markdown.md#link)
  * [Emphasis](markdown.md#em)
  * [Code](markdown.md#code)
  * [Images](markdown.md#img)
* [Miscellaneous](markdown.md#misc)
  * [Backslash Escapes](markdown.md#backslash)
  * [Automatic Links](markdown.md#autolink)

**Note:** This document is itself written using Markdown; Much of this document is based on the markdown guidelines of the [gomarkdown/markdown](https://github.com/gomarkdown/markdown) library.

***

## Kubecost Docs <a href="#docs" id="docs"></a>

Docs for Kubecost are hosted at: https://guide.kubecost.com

The `main` branch of the kubecost/docs repo is pulled and documents are updated daily.

### Titles <a href="#docs-titles" id="docs-titles"></a>

The first line of document should be the title as an H1 comment.

```
This is a Title
===============
```

### Links <a href="#docs-links" id="docs-links"></a>

To link to another doc use a GitHub link: `https://github.com/kubecost/docs/blob/main/*.md`

```
You can get the latest staging build by following the [install steps](https://github.com/kubecost/docs/blob/main/staging.md)
```

### Images <a href="#docs-images" id="docs-images"></a>

Use a direct link to the GitHub image within the kubecost/docs repo or an alternative host such as GCS or S3.

```
![Add key dialog](https://raw.githubusercontent.com/kubecost/docs/main/add-key-dialog.png)
```

At this time there aren't limits on the location of images within the kubecost/docs repo. Images may exist in the `/images` folder or in the root directory.

### Metadata <a href="#docs-metadata" id="docs-metadata"></a>

An HTML comment is used to store metadata about each document. An aritcle id, section, and permission group.

```
<!--- {"article":"","section":"","permissiongroup":""} --->
```

This metadata string must be the last line of the file. If no metadata string exists the file will be uploaded to the General category of the documentation.

### Categories and Sections <a href="#docs-cs" id="docs-cs"></a>

***

Architecture: `<!--- {"article":"","section":"4402829033367","permissiongroup":"1500001277122"} --->`

***

Azure `<!--- {"article":"","section":"4402815682455","permissiongroup":"1500001277122"} --->`

***

Using Kubecost `<!--- {"article":"","section":"4402815656599","permissiongroup":"1500001277122"} --->`

***

Setup `<!--- {"article":"","section":"4402815636375","permissiongroup":"1500001277122"} --->`

***

AWS `<!--- {"article":"","section":"4402829036567","permissiongroup":"1500001277122"} --->`

***

GCP `<!--- {"article":"","section":"4402815680407","permissiongroup":"1500001277122"} --->`

***

Troubleshooting `<!--- {"article":"","section":"4402815696919","permissiongroup":"1500001277122"} --->`

***

Kubecost ("General") `<!--- {"article":"","section":"1500002777682","permissiongroup":"1500001277122"} --->`

***

### Build and Deploy <a href="#doc-bd" id="doc-bd"></a>

The `main` branch of the kubecost/docs repo is pulled and documents on guide.kubecost.com are updated daily. During the build phase docs with an empty `article` string in the metadata will be created. Docs with an existing `article` string will be updated to reflect the latest changes.

### Create a New Doc <a href="#doc-create" id="doc-create"></a>

To create a new document submit a pull request including a markdown file and any image assets to the `main` branch of the kubecost/docs repo. After review and merge on GitHub a new document will be created on guide.kubecost.com once the build and deploy phase has completed. The metadata string of the new doc will be updated automatically on github with an `article` and `section`,`permissiongroup` info.

To create a new document in a specific section provide a metadata string with a `section` and `permissiongroup` and `article` as a blank string. Example:

```
Section Example Doc
===========

This will create a new doc in the "Setup" section!

<!--- {"article":"","section":"4402815636375","permissiongroup":"1500001277122"} --->
```

If no metadata string is provided the file will be uploaded to the General category of the documentation.

```
Example Doc
===========

No metadata? This will create a new doc in the "General" section!
```

### Update an Existing Doc <a href="#doc-update" id="doc-update"></a>

Submit changes to the file in a pull request to the `main` branch of the kubecost/docs repo. After review and merge on GitHub the document will be updated on guide.kubecost.com once the build and deploy phase has completed.

### Guide Markdown vs GitHub Markdown <a href="#doc-gg" id="doc-gg"></a>

Providing a seemless experience for consumers of the kubecost documentation GitHub and guide.kubecost.com is a goal of this project. Most of the supported formatting and features of GitHub flavored markdown should translate to guide.kubecost.com.

## Markdown Overview <a href="#overview" id="overview"></a>

### Inline HTML <a href="#html" id="html"></a>

Markdown's syntax is intended for one purpose: to be used as a format for _writing_ for the web.

The idea for Markdown is to make it easy to read, write, and edit prose. HTML is a _publishing_ format; Markdown is a _writing_ format. Thus, Markdown's formatting syntax only addresses issues that can be conveyed in plain text.

For any markup that is not covered by Markdown's syntax, you simply use HTML itself. There's no need to preface it or delimit it to indicate that you're switching from Markdown to HTML; you just use the tags.

The only restrictions are that block-level HTML elements -- e.g. `<div>`, `<table>`, `<pre>`, `<p>`, etc. -- must be separated from surrounding content by blank lines, and the start and end tags of the block should not be indented with tabs or spaces. Markdown is smart enough not to add extra (unwanted) `<p>` tags around HTML block-level tags.

For example, to add an HTML table to a Markdown article:

```
This is a regular paragraph.

<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>

This is another regular paragraph.
```

* Note that Markdown formatting syntax is not processed within block-level HTML tags

E.g., you can't use Markdown-style `*emphasis*` inside an HTML block.

Span-level HTML tags -- e.g. `<span>`, `<cite>`, or `<del>` -- can be used anywhere in a Markdown paragraph, list item, or header. If you want, you can even use HTML tags instead of Markdown formatting; e.g. if you'd prefer to use HTML `<a>` or `<img>` tags instead of Markdown's link or image syntax, go right ahead.

Unlike block-level HTML tags, Markdown syntax _is_ processed within span-level tags.

### Automatic Escaping for Special Characters <a href="#autoescape" id="autoescape"></a>

In HTML, there are two characters that demand special treatment: `<` and `&`. Left angle brackets are used to start tags; ampersands are used to denote HTML entities. If you want to use them as literal characters, you must escape them as entities, e.g. `&lt;`, and `&amp;`.

Ampersands in particular are bedeviling for web writers. If you want to write about 'AT\&T', you need to write '`AT&amp;T`'. You even need to escape ampersands within URLs. Thus, if you want to link to:

```
http://images.google.com/images?num=30&q=larry+bird
```

you need to encode the URL as:

```
http://images.google.com/images?num=30&amp;q=larry+bird
```

in your anchor tag `href` attribute. Needless to say, this is easy to forget, and is probably the single most common source of HTML validation errors in otherwise well-marked-up web sites.

Markdown allows you to use these characters naturally, taking care of all the necessary escaping for you. If you use an ampersand as part of an HTML entity, it remains unchanged; otherwise it will be translated into `&amp;`.

So, if you want to include a copyright symbol in your article, you can write:

```
&copy;
```

and Markdown will leave it alone. But if you write:

```
AT&T
```

Markdown will translate it to:

```
AT&amp;T
```

Similarly, because Markdown supports [inline HTML](markdown.md#html), if you use angle brackets as delimiters for HTML tags, Markdown will treat them as such. But if you write:

```
4 < 5
```

Markdown will translate it to:

```
4 &lt; 5
```

However, inside Markdown code spans and blocks, angle brackets and ampersands are _always_ encoded automatically. This makes it easy to use Markdown to write about HTML code. (As opposed to raw HTML, which is a terrible format for writing about HTML syntax, because every single `<` and `&` in your example code needs to be escaped.)

***

## HTML details tag <a href="#details" id="details"></a>

In GitHub markdown you can hide content with a `<details>` tag. While on guide.kubecost.com this same behavior is supported HTML must be used within the details tag body. Markdown will be converted to plan text.

## Block Elements <a href="#block" id="block"></a>

### Paragraphs and Line Breaks <a href="#p" id="p"></a>

A paragraph is simply one or more consecutive lines of text, separated by one or more blank lines. (A blank line is any line that looks like a blank line -- a line containing nothing but spaces or tabs is considered blank.) Normal paragraphs should not be intended with spaces or tabs.

The implication of the "one or more consecutive lines of text" rule is that Markdown supports "hard-wrapped" text paragraphs. This differs significantly from most other text-to-HTML formatters (including Movable Type's "Convert Line Breaks" option) which translate every line break character in a paragraph into a `<br />` tag.

When you _do_ want to insert a `<br />` break tag using Markdown, you end a line with two or more spaces, then type return.

Yes, this takes a tad more effort to create a `<br />`, but a simplistic "every line break is a `<br />`" rule wouldn't work for Markdown. Markdown's email-style [blockquoting](markdown.md#blockquote) and multi-paragraph [list items](markdown.md#list) work best -- and look better -- when you format them with hard breaks.

### Headers <a href="#header" id="header"></a>

Markdown supports two styles of headers, \[Setext] \[1] and \[atx] \[2].

Setext-style headers are "underlined" using equal signs (for first-level headers) and dashes (for second-level headers). For example:

```
This is an H1
=============

This is an H2
-------------
```

Any number of underlining `=`'s or `-`'s will work.

Atx-style headers use 1-6 hash characters at the start of the line, corresponding to header levels 1-6. For example:

```
# This is an H1

## This is an H2

###### This is an H6
```

Optionally, you may "close" atx-style headers. This is purely cosmetic -- you can use this if you think it looks better. The closing hashes don't even need to match the number of hashes used to open the header. (The number of opening hashes determines the header level.) :

```
# This is an H1 #

## This is an H2 ##

### This is an H3 ######
```

### Blockquotes <a href="#blockquote" id="blockquote"></a>

Markdown uses email-style `>` characters for blockquoting. If you're familiar with quoting passages of text in an email message, then you know how to create a blockquote in Markdown. It looks best if you hard wrap the text and put a `>` before every line:

```
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
> Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
> 
> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.
```

Markdown allows you to be lazy and only put the `>` before the first line of a hard-wrapped paragraph:

```
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.

> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus adipiscing.
```

Blockquotes can be nested (i.e. a blockquote-in-a-blockquote) by adding additional levels of `>`:

```
> This is the first level of quoting.
>
> > This is nested blockquote.
>
> Back to the first level.
```

Blockquotes can contain other Markdown elements, including headers, lists, and code blocks:

```
> ## This is a header.
> 
> 1.   This is the first list item.
> 2.   This is the second list item.
> 
> Here's some example code:
> 
>     return shell_exec("echo $input | $markdown_script");
```

Any decent text editor should make email-style quoting easy. For example, with BBEdit, you can make a selection and choose Increase Quote Level from the Text menu.

### Lists <a href="#list" id="list"></a>

Markdown supports ordered (numbered) and unordered (bulleted) lists.

Unordered lists use asterisks, pluses, and hyphens -- interchangably -- as list markers:

```
*   Red
*   Green
*   Blue
```

is equivalent to:

```
+   Red
+   Green
+   Blue
```

and:

```
-   Red
-   Green
-   Blue
```

Ordered lists use numbers followed by periods:

```
1.  Bird
2.  McHale
3.  Parish
```

It's important to note that the actual numbers you use to mark the list have no effect on the HTML output Markdown produces. The HTML Markdown produces from the above list is:

```
<ol>
<li>Bird</li>
<li>McHale</li>
<li>Parish</li>
</ol>
```

If you instead wrote the list in Markdown like this:

```
1.  Bird
1.  McHale
1.  Parish
```

or even:

```
3. Bird
1. McHale
8. Parish
```

you'd get the exact same HTML output. The point is, if you want to, you can use ordinal numbers in your ordered Markdown lists, so that the numbers in your source match the numbers in your published HTML. But if you want to be lazy, you don't have to.

If you do use lazy list numbering, however, you should still start the list with the number 1. At some point in the future, Markdown may support starting ordered lists at an arbitrary number.

List markers typically start at the left margin, but may be indented by up to three spaces. List markers must be followed by one or more spaces or a tab.

To make lists look nice, you can wrap items with hanging indents:

```
*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet vitae, risus.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.
```

But if you want to be lazy, you don't have to:

```
*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
viverra nec, fringilla in, laoreet vitae, risus.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
```

If list items are separated by blank lines, Markdown will wrap the items in `<p>` tags in the HTML output. For example, this input:

```
*   Bird
*   Magic
```

will turn into:

```
<ul>
<li>Bird</li>
<li>Magic</li>
</ul>
```

But this:

```
*   Bird

*   Magic
```

will turn into:

```
<ul>
<li><p>Bird</p></li>
<li><p>Magic</p></li>
</ul>
```

List items may consist of multiple paragraphs. Each subsequent paragraph in a list item must be intended by either 4 spaces or one tab:

```
1.  This is a list item with two paragraphs. Lorem ipsum dolor
    sit amet, consectetuer adipiscing elit. Aliquam hendrerit
    mi posuere lectus.

    Vestibulum enim wisi, viverra nec, fringilla in, laoreet
    vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
    sit amet velit.

2.  Suspendisse id sem consectetuer libero luctus adipiscing.
```

It looks nice if you indent every line of the subsequent paragraphs, but here again, Markdown will allow you to be lazy:

```
*   This is a list item with two paragraphs.

    This is the second paragraph in the list item. You're
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.

*   Another item in the same list.
```

To put a blockquote within a list item, the blockquote's `>` delimiters need to be indented:

```
*   A list item with a blockquote:

    > This is a blockquote
    > inside a list item.
```

To put a code block within a list item, the code block needs to be indented _twice_ -- 8 spaces or two tabs:

```
*   A list item with a code block:

        <code goes here>
```

It's worth noting that it's possible to trigger an ordered list by accident, by writing something like this:

```
1986. What a great season.
```

In other words, a _number-period-space_ sequence at the beginning of a line. To avoid this, you can backslash-escape the period:

```
1986\. What a great season.
```

### Code Blocks <a href="#precode" id="precode"></a>

Pre-formatted code blocks are used for writing about programming or markup source code. Rather than forming normal paragraphs, the lines of a code block are interpreted literally. Markdown wraps a code block in both `<pre>` and `<code>` tags.

To produce a code block in Markdown, simply indent every line of the block by at least 4 spaces or 1 tab. For example, given this input:

```
This is a normal paragraph:

    This is a code block.
```

Markdown will generate:

```
<p>This is a normal paragraph:</p>

<pre><code>This is a code block.
</code></pre>
```

One level of indentation -- 4 spaces or 1 tab -- is removed from each line of the code block. For example, this:

```
Here is an example of AppleScript:

    tell application "Foo"
        beep
    end tell
```

will turn into:

```
<p>Here is an example of AppleScript:</p>

<pre><code>tell application "Foo"
    beep
end tell
</code></pre>
```

A code block continues until it reaches a line that is not indented (or the end of the article).

Within a code block, ampersands (`&`) and angle brackets (`<` and `>`) are automatically converted into HTML entities. This makes it very easy to include example HTML source code using Markdown -- just paste it and indent it, and Markdown will handle the hassle of encoding the ampersands and angle brackets. For example, this:

```
    <div class="footer">
        &copy; 2004 Foo Corporation
    </div>
```

will turn into:

```
<pre><code>&lt;div class="footer"&gt;
    &amp;copy; 2004 Foo Corporation
&lt;/div&gt;
</code></pre>
```

Regular Markdown syntax is not processed within code blocks. E.g., asterisks are just literal asterisks within a code block. This means it's also easy to use Markdown to write about Markdown's own syntax.

### Horizontal Rules <a href="#hr" id="hr"></a>

You can produce a horizontal rule tag (`<hr />`) by placing three or more hyphens, asterisks, or underscores on a line by themselves. If you wish, you may use spaces between the hyphens or asterisks. Each of the following lines will produce a horizontal rule:

```
* * *

***

*****

- - -

---------------------------------------

_ _ _
```

***

## Span Elements <a href="#span" id="span"></a>

### Links <a href="#link" id="link"></a>

Markdown supports two style of links: _inline_ and _reference_.

In both styles, the link text is delimited by \[square brackets].

To create an inline link, use a set of regular parentheses immediately after the link text's closing square bracket. Inside the parentheses, put the URL where you want the link to point, along with an _optional_ title for the link, surrounded in quotes. For example:

```
This is [an example](http://example.com/ "Title") inline link.

[This link](http://example.net/) has no title attribute.
```

Will produce:

```
<p>This is <a href="http://example.com/" title="Title">
an example</a> inline link.</p>

<p><a href="http://example.net/">This link</a> has no
title attribute.</p>
```

If you're referring to a local resource on the same server, you can use relative paths:

```
See my [About](/about/) page for details.
```

Reference-style links use a second set of square brackets, inside which you place a label of your choosing to identify the link:

```
This is [an example][id] reference-style link.
```

You can optionally use a space to separate the sets of brackets:

```
This is [an example] [id] reference-style link.
```

Then, anywhere in the document, you define your link label like this, on a line by itself:

```
[id]: http://example.com/  "Optional Title Here"
```

That is:

* Square brackets containing the link identifier (optionally indented from the left margin using up to three spaces);
* followed by a colon;
* followed by one or more spaces (or tabs);
* followed by the URL for the link;
* optionally followed by a title attribute for the link, enclosed in double or single quotes.

The link URL may, optionally, be surrounded by angle brackets:

```
[id]: <http://example.com/>  "Optional Title Here"
```

You can put the title attribute on the next line and use extra spaces or tabs for padding, which tends to look better with longer URLs:

```
[id]: http://example.com/longish/path/to/resource/here
    "Optional Title Here"
```

Link definitions are only used for creating links during Markdown processing, and are stripped from your document in the HTML output.

Link definition names may constist of letters, numbers, spaces, and punctuation -- but they are _not_ case sensitive. E.g. these two links:

```
[link text][a]
[link text][A]
```

are equivalent.

The _implicit link name_ shortcut allows you to omit the name of the link, in which case the link text itself is used as the name. Just use an empty set of square brackets -- e.g., to link the word "Google" to the google.com web site, you could simply write:

```
[Google][]
```

And then define the link:

```
[Google]: http://google.com/
```

Because link names may contain spaces, this shortcut even works for multiple words in the link text:

```
Visit [Daring Fireball][] for more information.
```

And then define the link:

```
[Daring Fireball]: http://daringfireball.net/
```

Link definitions can be placed anywhere in your Markdown document. I tend to put them immediately after each paragraph in which they're used, but if you want, you can put them all at the end of your document, sort of like footnotes.

Here's an example of reference links in action:

```
I get 10 times more traffic from [Google] [1] than from
[Yahoo] [2] or [MSN] [3].

  [1]: http://google.com/        "Google"
  [2]: http://search.yahoo.com/  "Yahoo Search"
  [3]: http://search.msn.com/    "MSN Search"
```

Using the implicit link name shortcut, you could instead write:

```
I get 10 times more traffic from [Google][] than from
[Yahoo][] or [MSN][].

  [google]: http://google.com/        "Google"
  [yahoo]:  http://search.yahoo.com/  "Yahoo Search"
  [msn]:    http://search.msn.com/    "MSN Search"
```

Both of the above examples will produce the following HTML output:

```
<p>I get 10 times more traffic from <a href="http://google.com/"
title="Google">Google</a> than from
<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a>
or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
```

For comparison, here is the same paragraph written using Markdown's inline link style:

```
I get 10 times more traffic from [Google](http://google.com/ "Google")
than from [Yahoo](http://search.yahoo.com/ "Yahoo Search") or
[MSN](http://search.msn.com/ "MSN Search").
```

The point of reference-style links is not that they're easier to write. The point is that with reference-style links, your document source is vastly more readable. Compare the above examples: using reference-style links, the paragraph itself is only 81 characters long; with inline-style links, it's 176 characters; and as raw HTML, it's 234 characters. In the raw HTML, there's more markup than there is text.

With Markdown's reference-style links, a source document much more closely resembles the final output, as rendered in a browser. By allowing you to move the markup-related metadata out of the paragraph, you can add links without interrupting the narrative flow of your prose.

### Emphasis <a href="#em" id="em"></a>

Markdown treats asterisks (`*`) and underscores (`_`) as indicators of emphasis. Text wrapped with one `*` or `_` will be wrapped with an HTML `<em>` tag; double `*`'s or `_`'s will be wrapped with an HTML `<strong>` tag. E.g., this input:

```
*single asterisks*

_single underscores_

**double asterisks**

__double underscores__
```

will produce:

```
<em>single asterisks</em>

<em>single underscores</em>

<strong>double asterisks</strong>

<strong>double underscores</strong>
```

You can use whichever style you prefer; the lone restriction is that the same character must be used to open and close an emphasis span.

Emphasis can be used in the middle of a word:

Em_ph_asis

But if you surround an `*` or `_` with spaces, it'll be treated as a literal asterisk or underscore.

To produce a literal asterisk or underscore at a position where it would otherwise be used as an emphasis delimiter, you can backslash escape it:

```
\*this text is surrounded by literal asterisks\*
```

### Code <a href="#code" id="code"></a>

To indicate a span of code, wrap it with backtick quotes (`` ` ``). Unlike a pre-formatted code block, a code span indicates code within a normal paragraph. For example:

```
Use the `printf()` function.
```

will produce:

```
<p>Use the <code>printf()</code> function.</p>
```

To include a literal backtick character within a code span, you can use multiple backticks as the opening and closing delimiters:

```
``There is a literal backtick (`) here.``
```

which will produce this:

```
<p><code>There is a literal backtick (`) here.</code></p>
```

The backtick delimiters surrounding a code span may include spaces -- one after the opening, one before the closing. This allows you to place literal backtick characters at the beginning or end of a code span:

```
A single backtick in a code span: `` ` ``

A backtick-delimited string in a code span: `` `foo` ``
```

will produce:

```
<p>A single backtick in a code span: <code>`</code></p>

<p>A backtick-delimited string in a code span: <code>`foo`</code></p>
```

With a code span, ampersands and angle brackets are encoded as HTML entities automatically, which makes it easy to include example HTML tags. Markdown will turn this:

```
Please don't use any `<blink>` tags.
```

into:

```
<p>Please don't use any <code>&lt;blink&gt;</code> tags.</p>
```

You can write this:

```
`&#8212;` is the decimal-encoded equivalent of `&mdash;`.
```

to produce:

```
<p><code>&amp;#8212;</code> is the decimal-encoded
equivalent of <code>&amp;mdash;</code>.</p>
```

### Images <a href="#img" id="img"></a>

Admittedly, it's fairly difficult to devise a "natural" syntax for placing images into a plain text document format.

Markdown uses an image syntax that is intended to resemble the syntax for links, allowing for two styles: _inline_ and _reference_.

Inline image syntax looks like this:

```
![Alt text](/path/to/img.jpg)

![Alt text](/path/to/img.jpg "Optional title")
```

That is:

* An exclamation mark: `!`;
* followed by a set of square brackets, containing the `alt` attribute text for the image;
* followed by a set of parentheses, containing the URL or path to the image, and an optional `title` attribute enclosed in double or single quotes.

Reference-style image syntax looks like this:

```
![Alt text][id]
```

Where "id" is the name of a defined image reference. Image references are defined using syntax identical to link references:

```
[id]: url/to/image  "Optional title attribute"
```

As of this writing, Markdown has no syntax for specifying the dimensions of an image; if this is important to you, you can simply use regular HTML `<img>` tags.

***

## Miscellaneous <a href="#misc" id="misc"></a>

### Automatic Links <a href="#autolink" id="autolink"></a>

Markdown supports a shortcut style for creating "automatic" links for URLs and email addresses: simply surround the URL or email address with angle brackets. What this means is that if you want to show the actual text of a URL or email address, and also have it be a clickable link, you can do this:

```
<http://example.com/>
```

Markdown will turn this into:

```
<a href="http://example.com/">http://example.com/</a>
```

Automatic links for email addresses work similarly, except that Markdown will also perform a bit of randomized decimal and hex entity-encoding to help obscure your address from address-harvesting spambots. For example, Markdown will turn this:

```
<address@example.com>
```

into something like this:

```
<a href="&#x6D;&#x61;i&#x6C;&#x74;&#x6F;:&#x61;&#x64;&#x64;&#x72;&#x65;
&#115;&#115;&#64;&#101;&#120;&#x61;&#109;&#x70;&#x6C;e&#x2E;&#99;&#111;
&#109;">&#x61;&#x64;&#x64;&#x72;&#x65;&#115;&#115;&#64;&#101;&#120;&#x61;
&#109;&#x70;&#x6C;e&#x2E;&#99;&#111;&#109;</a>
```

which will render in a browser as a clickable link to "address@example.com".

(This sort of entity-encoding trick will indeed fool many, if not most, address-harvesting bots, but it definitely won't fool all of them. It's better than nothing, but an address published in this way will probably eventually start receiving spam.)

### Backslash Escapes <a href="#backslash" id="backslash"></a>

Markdown allows you to use backslash escapes to generate literal characters which would otherwise have special meaning in Markdown's formatting syntax. For example, if you wanted to surround a word with literal asterisks (instead of an HTML `<em>` tag), you can backslashes before the asterisks, like this:

```
\*literal asterisks\*
```

Markdown provides backslash escapes for the following characters:

```
\   backslash
`   backtick
*   asterisk
_   underscore
{}  curly braces
[]  square brackets
()  parentheses
#   hash mark
+	plus sign
-	minus sign (hyphen)
.   dot
!   exclamation mark
```


Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/markdown.md)


<!--- {"article":"4407604999447","section":"4402815656599","permissiongroup":"1500001277122"} --->