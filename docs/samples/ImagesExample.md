## CN1ML Sample: Images

[Return to Samples](../../README.md#more-samples)

This sample is part of the [CN1MLDemos](../../CN1MLDemos) project.

####Things to notice:

1. We use a GridLayout with parameters.  (Most of the other samples simply specify a class name for the `layout` attribute, but you can also pass parameters that will be used to instantiate the layout).
2. Each of the images referenced here is stored in the resource file as a multi-image.  The `res:` prefix tells the template to load the image from the resource file.  To reference an image on the classpath you need to use the `jar:` protocol.
3. In the [Usage](#usage) section, I comment on how to pass the `Resource` file to the template so that the template can access the images.

### CN1ML Source:

From [ImagesExample.cn1ml](../../CN1MLDemos/src/ca/weblite/codename1/cn1ml/demos/ImagesExample.cn1ml)

~~~
<html>
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
</html>
~~~

### Resulting Java Source:

From [ImagesExample.java](../../CN1MLDemos/src/ca/weblite/codename1/cn1ml/demos/ImagesExample.java)

~~~
/* THIS FILE IS AUTOMATICALLY GENERATED-- DO NOT MODIFY IT*/
package ca.weblite.codename1.cn1ml.demos;

import com.codename1.ui.*;
import com.codename1.ui.layouts.*;
import com.codename1.ui.table.*;
import com.codename1.ui.util.*;

class ImagesExample {

    private Container rootContainer;
    private Resources resources;

    public Container getRoot() {
        if (rootContainer == null) {
            try {
                rootContainer = buildUI();
            } catch (Exception ex) {
                ex.printStackTrace();
                throw new RuntimeException(ex.getMessage());
            }
        }
        return rootContainer;
    }
    private java.util.Map<String, Component> _nameIndex = new java.util.HashMap<String, Component>();

    public Component get(String name) {
        getRoot();
        return _nameIndex.get(name);
    }

    public ImagesExample(java.util.Map context) {
        for (Object o : context.values()) {
            if (o instanceof Resources) {
                resources = (Resources) o;
            }
        }
    }

    private Container buildUI() throws Exception {
        Container root = new Container();
        GridLayout rootLayout = new GridLayout(3, 3);
        root.setLayout(rootLayout);
        root.addComponent(new Label(resources.getImage("bills.gif")));
        root.addComponent(new Label(resources.getImage("bengals.gif")));
        root.addComponent(new Label(resources.getImage("browns.gif")));
        root.addComponent(new Label(resources.getImage("cardinals.gif")));
        root.addComponent(new Label(resources.getImage("cowboys.gif")));
        root.addComponent(new Label(resources.getImage("falcons.gif")));
        root.addComponent(new Label(resources.getImage("panthers.gif")));
        root.addComponent(new Label(resources.getImage("ravens.gif")));
        root.addComponent(new Label(resources.getImage("bears.gif")));
        return root;
    }
}

~~~


### Usage

From: [CN1MLDemo.java](../../CN1MLDemos/src/ca/weblite/codename1/cn1ml/demos/CN1MLDemo.java)

~~~
    private Resources theme;
    
    ...
    
    public void init(Object context) {
        ...
        theme = Resources.openLayered("/theme");
        ...
    }


    private HashMap newContext(){
        HashMap context = new HashMap();
        context.put("res", theme);
        return context;
    }
    
    ...
    
    private void showImagesExample(){
        ImagesExample e = new ImagesExample(newContext());
        createForm("Images Grid", e.getRoot()).show();
    }
    
~~~

In this example, I have highlighted how the `newContext()` method is implemented to create a context for the template because it this template makes use of a resource file to load all of the images.  Notice that we add the "theme" to the context:

~~~
context.put("res", theme);
~~~

It doesn't matter what we use for a key.  I.e. instead of "res" would could have used anything else like "foo" etc...  The template will look for a value of type "Resources" and store this as teh resource for any images that are addressed using the "res:" protocol.

### Screenshots

![iOS Screenshot](screenshots/ImagesExample-ios.png)