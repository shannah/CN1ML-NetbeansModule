/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package ca.weblite.codename1.netbeans.cn1ml;

import ca.weblite.codename1.cn1ml.CN1ML;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import javax.swing.text.BadLocationException;
import javax.swing.text.Document;

import org.netbeans.api.editor.mimelookup.MimeRegistration;
import org.netbeans.api.java.project.JavaProjectConstants;
import org.netbeans.api.project.FileOwnerQuery;
import org.netbeans.api.project.Project;
import org.netbeans.api.project.ProjectUtils;
import org.netbeans.api.project.SourceGroup;
import org.netbeans.api.project.Sources;
import org.netbeans.editor.BaseDocument;
import org.netbeans.modules.editor.NbEditorUtilities;
import org.netbeans.modules.editor.indent.api.Reformat;
import org.netbeans.modules.parsing.api.Source;
import org.netbeans.spi.editor.document.OnSaveTask;
import org.openide.filesystems.FileObject;
import org.openide.filesystems.FileUtil;
import org.openide.util.Exceptions;

/**
 *
 * @author shannah
 */
public class CN1MLOnSaveTask implements OnSaveTask {

    Context context;
    
    private CN1MLOnSaveTask(Context context){
        this.context = context;
    }
    
    @Override
    public void performTask() {
        try {
            FileObject fo = NbEditorUtilities.getFileObject(context.getDocument());
            
            String className = getFullyQualifiedClassName(fo);
            
            Document doc = context.getDocument();
            String html = doc.getText(0, doc.getLength());
            CN1ML cn1ml = new CN1ML(className);
            String result = cn1ml.buildClass(html);
            
            String classFilePath = fo.getPath().substring(0, fo.getPath().lastIndexOf(".")) + ".java";
            File out = new File(classFilePath);
            FileOutputStream fos = null;
            try {
                fos = new FileOutputStream(out);
               
                fos.write(result.getBytes("UTF-8"));
            } catch (FileNotFoundException ex) {
                Exceptions.printStackTrace(ex);
            } catch (IOException ex) {
                Exceptions.printStackTrace(ex);
            } finally {
                if ( fos != null  ){
                    try {
                        fos.close();
                    } catch ( Exception ex){}
                }
            }
            
            
            BaseDocument javaDoc = (BaseDocument)Source.create(FileUtil.toFileObject(out)).getDocument(true);
            
            
            
            Reformat f = Reformat.get(javaDoc);
            f.lock();
            try {
                if ( f==null ){
                    System.out.println("Reformat is null");
                }
                if ( javaDoc == null ){
                    System.out.println("Java doc is null");
                }
                f.reformat(0, javaDoc.getLength());
                
            } finally {
                f.unlock();
            }
            System.out.println(javaDoc.getText());
        } catch (BadLocationException ex) {
            Exceptions.printStackTrace(ex);
        }
    }

    @Override
    public void runLocked(Runnable r) {
        performTask();
    }

    @Override
    public boolean cancel() {
        System.out.println("Cancelling....");
        return false;
    }
    
    
    @MimeRegistration(mimeType="text/cn1ml+xml", service=OnSaveTask.Factory.class, position=1500)
    public static class Factory implements OnSaveTask.Factory {

        @Override
        public OnSaveTask createTask(Context cntxt) {
            
            return new CN1MLOnSaveTask(cntxt);
        }
        
    }
    
    private FileObject getRoot(FileObject file){
        Project project = FileOwnerQuery.getOwner(file);
        Sources sources = ProjectUtils.getSources(project);
        for (SourceGroup sourceGroup : sources.getSourceGroups(JavaProjectConstants.SOURCES_TYPE_JAVA)) {
            FileObject root = sourceGroup.getRootFolder();
            if ( FileUtil.isParentOf(root, file) || root.equals(file)){
                return root;
            }
        }
        return null;
    }
    
    private String getFullyQualifiedClassName(FileObject file){
        FileObject root = getRoot(file);
        String relPath = FileUtil.getRelativePath(root, file);
        relPath = relPath.substring(0, relPath.lastIndexOf("."));
        return relPath.replaceAll("/", ".");
    }
    
    
}
