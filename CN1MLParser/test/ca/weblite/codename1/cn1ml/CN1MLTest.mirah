/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package ca.weblite.codename1.cn1ml
import org.junit.Test
import org.jsoup.Jsoup
import org.jsoup.nodes.Entities.EscapeMode
import static org.junit.Assert.*



class CN1MLTest 
  /*
  $Test
  def test1:void
    testHtml = CN1MLTest.class.getResourceAsStream('test.html')
    writer = CN1ML.new 'mypkg.layouts.Test'
    out = writer.buildClass(testHtml)
    puts "Result: #{out}"
  end
  
  $Test
  def testTableTagLayout:void
    html = "<table id='el'></table>"
    doc = Jsoup.parse html
    table = doc.getElementById('el')
    
    writer = CN1ML.new 'MyClass'
    cls = writer.getLayoutClass table
    assertEquals "Class should be TableLayout but found #{cls}", 'TableLayout', cls
  end
  
  $Test
  def testResolveTableTagLayout:void
    
    
    
    html = "<table id='el'></table>"
    doc = Jsoup.parse html
    table = doc.getElementById('el')
    
    writer = CN1ML.new 'MyClass'
    
    #writer.test
    
    cls = writer.resolveLayoutDirective table
    assertEquals "Class should be TableLayout() but found #{cls}", 'TableLayout(1, 1)', cls
  end
  
  
  $Test
  def testTransformTableTag:void
    html = "<table id='el'>
      <tr><td>Name</td><td><input type='text'/></td></tr>
      <tr><td colspan='2'>BIO</td></tr>
      <tr><td colspan='2'><textarea></textarea></td></tr>
    </table>"
    writer = CN1ML.new 'MyClass'
    doc = Jsoup.parse html
    
    writer.preprocessDom(doc)
    puts doc.html
  end
  */
  
  $Test
  def testTransformSelectTag:void
      html = "<table><tr><td name='theTD' layout='y'><select><option>Florida</option><option>Washi&quot;ngton</option><option>Virginia</option></select></td></tr>
        <tr><td><textarea rows='5' readonly='1'>Some text</textarea></td></tr>
      </table>"
    writer = CN1ML.new 'pkg.MyClass'
    doc = Jsoup.parse html
    
    writer.preprocessDom(doc)
    puts doc.html
    
    classText = writer.buildClass html
    puts classText
  end
  
  $Test
  def testEscape:void
      assertEquals 'Washing\\"ton', CN1ML.new("foo.bar").escape('Washing"ton')
  end
  
end

