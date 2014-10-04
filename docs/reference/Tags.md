#CN1ML Tag Reference

##Contents

1. [Overview](#overview)
2. [HTML Tags](#html-tags)
3. [Layouts](#layouts)
4. [Template Attributes and Parameters](#attributes)
5. [Client Properties](#putting-client-properties)
6. [Custom Initialization: Script tags](#script-tags)
7. [Imports](#imports)
8. [UIIDs](#uiids)
9. [Tables](#tables)
10. [Images](#images)
11. [Text](#text)
12. [Lists](#lists)

##Overview

In CN1ML, you can use any HTML (or non-HTML) tag in your document.  The default Component that will be used to represent a tag is `com.codename1.ui.Container`, but some tags are handled specially and will be converted to a more appropriate Component (e.g. `<label>` is converted to `com.codename1.ui.Label`, etc..).

In addition, you can use the `class` attribute on any tag to specify a particular `Component` subclass.

This document outlines the rules that are used by the CN1ML parser for converting HTML tags.

<hr>

##HTML Tags

| HTML Tag		| Component |
|--------------|-------------|
| `<label>`      | `com.codename1.ui.Label`|
| `<button>`     | `com.codename1.ui.Button`|
| `<textarea>`   | `com.codename1.ui.TextArea`|
| `<input type="text">` | `com.codename1.ui.TextField`|
| `<input type="checkbox">` | `com.codename1.ui.CheckBox`|
| `<input type="radio">` | `com.codename1.ui.RadioButton` |
| `<select>` | `com.codename1.ui.ComboBox` |
| `<select size="5">` | `com.codename1.ui.List`|
| `<img>` | `com.codename1.ui.Label`|
| `<table>` | `com.codename1.ui.Container`|
| `<div>` | `com.codename1.ui.Container`|
| `<script>` |Converted to Java code block |
| `<body>` | `com.codename1.ui.Container` -- this is the root|

All tags not listed in the above table are converted to `Container` objects, except in cases where the tag is a child of a "special component" that overrides the behaviour of its children (like a `<table>` with its `<tr>` tags).


<hr>


##Layouts

Use the `layout` attribute on any tag (that converts to a `Container` or subclass thereof) to specify the layout manager that should be used with the container.  The default layout, if this is omitted, will be `FlowLayout`.

e.g.

~~~
 <div layout="BorderLayout">...</div>
 <div layout="GridLayout(3,3)">...</div>
 <div layout="BoxLayout(BoxLayout.Y_AXIS)">...</div>
 <div layout="com.mycompany.layouts.MyCustomLayout">...</div>
~~~

Some common layouts have short-cuts:

| Layout | ShortCut | Example|
|---------|----------|---------|
| `BoxLayout(BoxLayout.X_AXIS)` | `X_AXIS`| `<div layout="X_AXIS">...</div>`|
| `BoxLayout(BoxLayout.Y_AXIS)` | `Y_AXIS`| `<div layout="Y_AXIS">...</div>`|
| `BoxLayout(BoxLayout.X_AXIS)` | `x`| `<div layout="x">...</div>`|
| `BoxLayout(BoxLayout.Y_AXIS)` | `y`| `<div layout="y">...</div>`|


###Layout Constraints

Some layout managers require a constraint when adding child components.  E.g. When adding a component to a Container that uses BorderLayout, you need to specify one of `BorderLayout.NORTH`, `BorderLayout.SOUTH`, `BorderLayout.CENTER`, etc... as the first parameter of `addComponent()` so that it knows where to place the component.

Use the `layout-constraint` attribute on the child tag to specify this constraint.

e.g.

~~~
 <div layout="BorderLayout">
    <div layout-constraint="BorderLayout.NORTH">North panel</div>
    <div layout-constraint="BorderLayout.CENTER">Center panel</div>
 </div>
~~~

Some common constraints have shortcuts:

| Constraint | Shortcut | Example |
| -----------| ---------| --------|
| `BorderLayout.NORTH` | `NORTH` | `<div layout-constraint="NORTH">...</div>`|
| `BorderLayout.SOUTH` | `SOUTH` | `<div layout-constraint="SOUTH">...</div>`|
| `BorderLayout.CENTER` | `CENTER` | `<div layout-constraint="CENTER">...</div>`|
| `BorderLayout.WEST` | `WEST` | `<div layout-constraint="WEST">...</div>`|
| `BorderLayout.EAST` | `EAST` | `<div layout-constraint="EAST">...</div>`|
| `BorderLayout.NORTH` | `n` | `<div layout-constraint="n">...</div>`|
| `BorderLayout.SOUTH` | `s` | `<div layout-constraint="s">...</div>`|
| `BorderLayout.CENTER` | `c` | `<div layout-constraint="c">...</div>`|
| `BorderLayout.WEST` | `w` | `<div layout-constraint="w">...</div>`|
| `BorderLayout.EAST` | `e` | `<div layout-constraint="e">...</div>`|


If you have a custom constraint, you can specify that using a java expression:

~~~
 <div layout-constraint="new com.mycompany.myapp.MyConstraing(1,2)">...</div>
~~~

<hr>

<a name="attributes"></a>

## Template Attributes/Parameters

CN1ML allows you to pass data to the template and use this data inside expressions in various element attributes.  This allows you to add an extra degree of dynamism to the template.  Parameters are defined by the `attributes` attribute of the `<body>` tag.  They are expressed as Java Classname/VarName pairs - with multiple pairs separated by semi-colons.  E.g.

~~~
<body attributes="String[] menuItems; int gridWidth; int gridHeight;">...</body>
~~~

Then, these properties can be used either inside `<script>` tags or as part of HTML attributes where java expressions are allowed.

E.g.

~~~
 <div layout="GridLayout(gridWidth, gridHeight)">...</div>
~~~

or

~~~
 <select data="menuItems"></select>
~~~

####Using Templates that Require Attributes

When using a template that expects to receive attributes, you will need to provide the attribute values to the template's constructor.  E.g.  The template from the previous example would need to be instantiated as follows:

~~~
Map context = new HashMap();
context.put("menuItems", new String[]{"Item 1", "Item 2", "Item 3"});
context.put("gridWidth", 3);
context.put("gridHeight", 4);
MyForm f = new MyForm(context);
~~~

<hr>

## Putting Client Properties

The Codename One `Component` class includes a handy method `putClientProperty` that allows you to bind an arbitrary object to a UI component.  CN1ML supports this by way of `data-xxx` attributes.  If a tag includes an attribute of the form `data-xxx`, the value of the attribute will be added to the resulting UI component as a client property.

E.g.

~~~
 <div data-playerName="Steve">...</div>
~~~

Will result in the component having something:

~~~
 cmp.putClientProperty("playerName", "Steve");
~~~

`data-xxx` attributes are assumed to be strings unless they are prefixed with "java:", which indicates that what follows is a java expression whose result should be added to the component's client properties.

E.g.

~~~
<body attributes="com.myapp.Player player1;">
    <div name="player1ScoreBoard" data-player="java:player1">..</div>
</body>
~~~


In the above example, the template expects to receive a property named `player1` of type `com.myapp.Player`.  This is set as a client property for the Container named `player1ScoreBoard`.

<hr>
<a name="script-tags"></a>

##Custom Initialization: Script tags

Some components require custom initialization that can't be expressed with the existing HTML tags and attributes.  In cases like this, you can use a `<script>` tag to add your own custom Java code that will be run when the UI is built.

`<script>`s are always executed in the context of the parent component of the script tag, and the Component will be accessible to the script via the `self` variable.

**Special Variables in Scripts and their Meanings**

|  Variable | Meaning |
|-----------|---------|
| `self` | The `Component` that is the parent of the `<script>`|
| `this` | The template class. |
| `parent` | The parent `Component` of `self` |


**Some Examples**

~~~
 <div>
   <script>
     self.setScrollable(true);
   </script>
 </div>
~~~

In this example, the `Container` that the `<div>` tag is transformed into will be made scrollable.


~~~
<button name="google">Google
	<script>
	   self.addActionListener(new ActionListener(){
	       public void actionPerformed(ActionEvent e){
	           getBrowser().setURL("http://google.com");
	       }
	   });
	</script>
</button>
~~~

In the above example, we use a script to attach an action listener to the button.  In this case we are also making use of the automatic accessors that are generated by the template -- (the getBrowser() method is the result of a tag with `name="browser"` somewhere else in the template).



##Imports

Just like with a regular Java source file, you may find it annoying to have to use the fully-qualified class name every time you want to reference a class.   CN1ML automatically imports some of the common packages (e.g. com.codename1.ui.*, com.codename1.ui.layouts.*, etc..), but you may feel the need to import others.

You can add imports to your template by adding them inside a `<script>` tag in the `<head>` of the document.

E.g.

~~~
 <head>
    <script>
      import com.mycompany.myapp.*;
    </script>
 </head>
~~~

<hr>

##UIIDs

Use the `uiid` attribute to specify the UIID of any component.  This will allow you to use the standard Codename One method for customizing the look and feel of your template.  This is a nice alternative to CSS.

e.g.

~~~
 <label uiid="Title">Some Title Text</label>
~~~

<hr>

##Tables

Codename One supports a `TableLayout` that allows you to layout content as a table.  To set this up programmatically it is quite painful since each cell needs to have a `TableLayout.Constraint` created to specify the column and row settings of the cell.  CN1ML simplifies this process greatly by supporting `<table>` tags which automatically generate the appropriate code.

`<td>` tags support the `colspan` and `rowspan` attributes if you want to create complex table structures.

e.g.

~~~
 <table>
    <tr>
        <td>First Name</td>
        <td><input type="text" name="firstName"/></td>
    </tr>
    <tr>
        <td>Last Name</td>
        <td><input type="text" name="lastName"/></td>
    </tr>
    <tr>
        <td>Home Country</td>
        <td>
            <select name="countrySelect">
                <option>Canada</option>
                <option>United States</option>
                <option>France</option>
                <option>Spain</option>
            </select>
        </td>
    </tr>
    <tr>
        <td colspan="2">Bio (Paragraph)</td>
    </tr>
    <tr>
        <td colspan="2">
            <textarea name="bio" rows="5" cols="30"></textarea>
        </td>
    </tr>
 </table>

~~~


### Dynamically Building Tables

Sometimes you may want to build a table, but you don't want to manually include all of the cells inside the template.  Perhaps you have a data source that you intend to iterate over in code to populate the cells of the table.  In this case, you may just want to specify that the table has a particular number of rows and columns.

Use the `rows` and `cols` attributes of the `<table>` tag for this.

e.g.

~~~
 <table rows="5" cols="10"></table.
~~~

You can also use a Java expression for these attributes.

e.g.

~~~
 <table rows="board.getHeight()" cols="board.getWidth()"></table.
~~~

<hr>

<a name="images"></a>

## Images (the `<img>` tag)

CN1ML supports the `<img>` tag for including images in your UI.  Currently it allows you to reference images from a resource file, or the class path.  Use the `src` attribute to specify the image to use.  Images in the resource file should be prefixed with `res:` and images on the classpath should be prefixed with `jar:`.

E.g.

~~~
 <body layout="GridLayout(3,3)">
     <img src="res:bills.gif"/>
     <img src="res:bengals.gif"/>
     <img src="res:browns.gif"/>
     <img src="res:cardinals.gif"/>
     <img src="res:cowboys.gif"/>
     <img src="res:falcons.gif"/>
     <img src="res:panthers.gif"/>
     <img src="res:ravens.gif"/>
     <img src="res:bears.gif"/>
 </body>
~~~

**Note:** In order to reference a resource file, you must pass at least one `Resources` object to the template's constructor.  It doesn't matter what the key of this is.  See [ImagesExample](../samples/ImagesExample.md) for a complete example.

###Images in Labels and Buttons

`<img>` tags that are inside a `<label>` or `<button>` tag will be set as the parent `Label` or `Button`'s icon.  `<img>` tags occurring elsewhere inside the template will simply be wrapped in their own anonymous `<label>`.

<hr>

##Text

You can place text anywhere inside the template.  It the text is placed inside a `<label>`, `<button>`, or `<textarea>` tag, it will be set as the text of the resulting `Label`, `Button`, or `TextArea`.  Text occurring elsewhere in the template will be automatically wrapped in an anonymous `Label`.

<hr>
<a name="lists"></a>

##Lists and Combo Boxes

Use the `<select>` tag to add a list or Combo Box to the UI. By default a `<select>` will be converted to a `ComboBox`, but if you add the `size` attribute with a number greater than 1, it will convert to a `List`.

e.g.

~~~
<!-- Convert to combo box-->
<select>
   <option>Opt 1</option>
   <option>Opt 2</option>
   <option>Opt 3</option>
</select>

<!-- Convert to List -->
<select size="5">
   <option>Opt 1</option>
   <option>Opt 2</option>
   <option>Opt 3</option>
</select>

~~~


### Dynamic Lists

You can provide the list with dynamic data for its model using the `data` attribute.  If the data is a `ListModel` object, then you can provide it using the `model` attribute.

E.g.

~~~
 <!-- Provide data (a Collection or array) -->
 <select data="menuItems"></select>
 
 <!-- Provide a list model -->
 <select model="myModel"></select>
~~~

Both of these examples require that you pass the data to the template as an attribute.
