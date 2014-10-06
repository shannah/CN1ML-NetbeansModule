package ca.weblite.codename1.cn1ml.demos;


import com.codename1.ui.Command;
import com.codename1.ui.Component;
import com.codename1.ui.Display;
import com.codename1.ui.Form;
import com.codename1.ui.Label;
import com.codename1.ui.events.ActionEvent;
import com.codename1.ui.events.ActionListener;
import com.codename1.ui.layouts.BorderLayout;
import com.codename1.ui.plaf.UIManager;
import com.codename1.ui.util.Resources;
import java.io.IOException;
import java.util.HashMap;

public class CN1MLDemo {

    private Form current;
    private Resources theme;
    public void init(Object context) {
        try {
            theme = Resources.openLayered("/theme");
            UIManager.getInstance().setThemeProps(theme.getTheme(theme.getThemeResourceNames()[0]));
            
        } catch(IOException e){
            e.printStackTrace();
        }
        // Pro users - uncomment this code to get crash reports sent to you automatically
        /*Display.getInstance().addEdtErrorHandler(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                evt.consume();
                Log.p("Exception in AppName version " + Display.getInstance().getProperty("AppVersion", "Unknown"));
                Log.p("OS " + Display.getInstance().getPlatformName());
                Log.p("Error " + evt.getSource());
                Log.p("Current Form " + Display.getInstance().getCurrent().getName());
                Log.e((Throwable)evt.getSource());
                Log.sendLog();
            }
        });*/
    }
    
    public void start() {
        if(current != null){
            current.show();
            return;
        }
       showMainMenu();
    }

    private Form createForm(String title, Component content){
        Form f = new Form(title);
        f.setLayout(new BorderLayout());
        f.addComponent(BorderLayout.CENTER, content);
        if (!"Main Menu".equals(title)){
            f.setBackCommand(new Command("Main Menu"){

                @Override
                public void actionPerformed(ActionEvent evt) {
                    createForm("Main Menu", getMainMenu()).showBack();
                }

            });
        }   
        return f;
    }
    
    private Component getMainMenu(){
        HashMap context = new HashMap();
        context.put("res", theme);
        context.put("menuItems", new String[]{
            "Simple List",
            "Contact Form",
            "Contact Form i18n",
            "Map",
            "Web Browser",
            "Default Sample Template",
            "Images Example",
            "My Old Form",
            "Tabs Demo"
        });
        final MainMenu m = new MainMenu(context);
        m.getMenuList().addActionListener(new ActionListener(){

            public void actionPerformed(ActionEvent evt) {
                String sel = (String)m.getMenuList().getSelectedItem();
                if ("Simple List".equals(sel)){
                    showSimpleList();
                } else if ( "Contact Form".equals(sel)){
                    showContactForm();
                } else if ( "Contact Form i18n".equals(sel)){
                    showContactFormI18n();
                } else if ("Map".equals(sel)){
                    showMap();
                } else if ("Web Browser".equals(sel)){
                    showWebBrowser();
                } else if ("Default Sample Template".equals(sel)){
                    showMyNewForm();
                } else if ("Images Example".equals(sel)){
                    showImagesExample();
                } else if ( "My Old Form".equals(sel)){
                    showMyOldForm();
                } else if ("Tabs Demo".equals(sel)){
                    showTabsDemo();
                }
            }
            
        });
        
        return m.getRoot();
        
    }
    
    private void showMainMenu(){
        createForm("CN1ML Demos", getMainMenu()).show();
    }
    
    private void showSimpleList(){
        SimpleList l = new SimpleList(newContext());
        
        createForm("Simple List", l.getRoot()).show();
    }
    
    private HashMap newContext(){
        HashMap context = new HashMap();
        context.put("res", theme);
        return context;
    }
    
    private void showContactForm(){
        ContactForm f = new ContactForm(newContext());
        createForm("Contact Form", f.getRoot()).show();
    }
    
    private void showContactFormI18n(){
        ContactFormI18n f = new ContactFormI18n(newContext());
        UIManager.getInstance().setBundle(theme.getL10N("ContactFormI18n", "fr"));
        createForm("Contact Form i18n", f.getRoot()).show();
    }
    
    private void showMap(){
        Map m = new Map(newContext());
        createForm("Map", m.getRoot()).show();
    }
    
    private void showWebBrowser(){
        WebBrowser m = new WebBrowser(newContext());
        createForm("Web Browser", m.getRoot()).show();
    }
    
    private void showImagesExample(){
        ImagesExample e = new ImagesExample(newContext());
        createForm("Images Grid", e.getRoot()).show();
    }
    
    private void showMyOldForm(){
        MyOldForm f = new MyOldForm(newContext());
        
        createForm("Old Form", f.getRoot()).show();
    }
    
    private void showTabsDemo(){
        TabsDemo f = new TabsDemo(newContext());
        createForm("Tabs Demo", f.getRoot()).show();
    }
    
    private void showMyNewForm(){
        
        // Instantiate the MyNewForm class.
        // Takes a Map in the constructor as a means of passing data to the
        // template.
        MyNewForm f = new MyNewForm(new HashMap());
        
        // Create a new form to show our template
        Form form = new Form("My New Form");
        form.setLayout(new BorderLayout());
        
        // Add the MyNewForm to the form.
        // Use the getRoot() method to get the root container 
        // corresponding to the <body> tag.
        form.addComponent(BorderLayout.CENTER, f.getRoot());
        
        // Show the form
        form.show();
    }
    
    public void stop() {
        current = Display.getInstance().getCurrent();
    }
    
    public void destroy() {
    }

}
