package ca.weblite.codename1.cn1ml
import java.io.InputStream
import org.jsoup.nodes.Document
import org.jsoup.nodes.Element
import org.jsoup.nodes.Node
import java.io.ByteArrayInputStream
import java.nio.charset.StandardCharsets
import org.jsoup.nodes.TextNode
import org.jsoup.nodes.DataNode
import org.jsoup.Jsoup



/**
 *
 * @author shannah
 */
class CN1ML 
  
  @@COMPONENT='com.codename1.ui.Component'
  @@CONTAINER='com.codename1.ui.Container'
  
  @@UIClasses = {
    'div' => 'Container',
    'span' => 'Container',
    'label' => 'Label',
    'button' => 'Button',
    'table' => 'Container',
    'textarea' => 'TextArea',
    'select' => 'ComboBox'
  }
  
  @@DEFAULT_LAYOUTS = {
    'table' => 'TableLayout',
    'ul' => 'BoxLayout'
  }
  
  @@LAYOUT_SHORTCUTS = {
    'X_AXIS' => 'BoxLayout(BoxLayout.X_AXIS)',
    'Y_AXIS' => 'BoxLayout(BoxLayout.Y_AXIS)',
    'x' => 'BoxLayout(BoxLayout.X_AXIS)',
    'y' => 'BoxLayout(BoxLayout.Y_AXIS)'
  }
  
  @@LAYOUT_CONSTRAINT_SHORTCUTS = {
    'NORTH' => 'BorderLayout.NORTH',
    'SOUTH' => 'BorderLayout.SOUTH',
    'EAST' => 'BorderLayout.EAST',
    'WEST' => 'BorderLayout.WEST',
    'CENTER' => 'BorderLayout.CENTER',
    'north' => 'BorderLayout.NORTH',
    'south' => 'BorderLayout.SOUTH',
    'east' => 'BorderLayout.EAST',
    'west' => 'BorderLayout.WEST',
    'center' => 'BorderLayout.CENTER',
    'n' => 'BorderLayout.NORTH',
    's' => 'BorderLayout.SOUTH',
    'e' => 'BorderLayout.EAST',
    'w' => 'BorderLayout.WEST',
    'c' => 'BorderLayout.CENTER'
  }
  
  def initialize(className:String)
    @className=className
    
  end
  
  def buildClass(html:String):String
    buildClass ByteArrayInputStream.new html.getBytes(StandardCharsets.UTF_8)
  end
  
  # DOM PREPROCESSING METHODS ##################################################
  # --------------------------
  # These methods are called prior to the conversion to transform the DOM into
  # A normalized form that the parser can handle more easily.  This is helpful
  # for "special" tags like <table>, and <textarea> where the nested elements
  # won't correspond to nested elements in the CN1 component model.
  
  
  def preprocessDom(doc:Document):void
    preprocessI18n doc.body
    preprocessElement doc.body
  end
  
  def preprocessTabsElement(el:Element):void
    if el.attr('class').length == 0
      el.attr 'class', 'Tabs'
    end
    el.children.each do |child|
      scriptContent = StringBuilder.new
      next if child.attr('title').length == 0
      title = child.attr 'title'
      title = if title.indexOf('java:')==0
        title.substring(title.indexOf(':')+1)
      else
        "\"#{escape(title)}\""
      end
      
      if child.attr('icon').length > 0
        icon = getImgSrc child.attr 'icon'
        scriptContent << "parent.addTab(#{title}, #{icon}, self);\n"
      else
        scriptContent << "parent.addTab(#{title}, self);\n"
      end
      scriptContent << "self.putClientProperty(\"__CN1ML_NO_ADD__\", \"NO_ADD\");\n"
      script = el.ownerDocument.createElement 'script'
      script.appendChild DataNode.new scriptContent.toString, ""
      child.appendChild script
    end
    
    el.children.each do |child|
      preprocessElement child
    end
  end
  
  def preprocessTextAreaElement(el:Element):void
      textContent = el.text
      rows = if el.attr('rows') .length > 0
          el.attr 'rows'
      else
          nil
      end
      cols = if el.attr('cols') .length > 0
          el.attr 'cols'
      else
          nil
      end
      
      div = el.ownerDocument.createElement 'div'
      el.attributes.each {|att| div.attr att.getKey, att.getValue}
      div.attr 'class', 'TextArea'
      
      if rows
        script = el.ownerDocument.createElement 'script'
        script.appendChild DataNode.new "self.setRows(#{rows});\n", ""
        div.appendChild script
      end
      if cols
        script = el.ownerDocument.createElement 'script'
        script.appendChild DataNode.new "self.setColumns(#{cols});\n", ""
        div.appendChild script
      end
      if textContent.length>0
        script = el.ownerDocument.createElement 'script'
        script.appendChild DataNode.new "self.setText(\"#{escape textContent}\");\n", ""
        div.appendChild script
      end
      if el.attr('readonly').length>0
        script = el.ownerDocument.createElement 'script'
        script.appendChild DataNode.new "self.setEditable(false);\n", ""
        div.appendChild script
      end
      
      findChildren('script', el).each do |scr|
        scr.remove
        div.appendChild(scr)
      end
      el.replaceWith(div)
  end
  
  def preprocessTableElement(el:Element):void
    tbody = findOne 'tbody', el
    div = el.ownerDocument.createElement 'div'
    el.attributes.each do |att|
      div.attr att.getKey, att.getValue
    end
    rows = el.attr 'rows'
    cols = el.attr 'cols'
    
    return if rows.length>0 and cols.length > 0
    if rows.length == 0
      trTags = if tbody
        findChildren 'tr', tbody
      else 
        findChildren 'tr', el
      end
      
      rows = "#{trTags.length}"
    end
    
    if cols.length == 0
      numCols = 0
      trTags = if tbody
        findChildren 'tr', tbody
      else 
        findChildren 'tr', el
      end
      
      trTags.each do |tr|
        findChildren('td', tr).each do |td|
          if td.attr('colspan').length > 0
            numCols += Integer.parseInt(td.attr('colspan'))
          else
            numCols += 1
          end
          
        end
        break
      end
      
      cols = "#{numCols}"
    end
    
    div.attr 'layout', "TableLayout(#{rows},#{cols})"
    trTags = if tbody
      findChildren 'tr', tbody
    else 
      findChildren 'tr', el
    end
    
    
    # Grid to keep track of of row spans of each column
    rowSpanStacks = []
    Integer.parseInt(cols).times {|iter| rowSpanStacks[iter]=0}
    
      
    currRow=0
    trTags.each do |tr|
      currCol=0
      findChildren('td', tr).each do |td|
        while rowSpanStacks[currCol].intValue > 0
          rowSpanStacks[currCol] = rowSpanStacks[currCol].intValue-1
          currCol += 1
        end
        cellDiv = el.ownerDocument.createElement 'div'
        td.attributes.each {|att| cellDiv.attr att.getKey, att.getValue}
        rowSpan=if td.attr('rowspan').length>0
          Integer.parseInt(td.attr 'rowspan')
        else
          1
        end
        
        colSpan=if td.attr('colspan').length>0
          Integer.parseInt(td.attr 'colspan')
        else
          1
        end
        
        if rowSpan > 1
          currCol.upto(currCol+colSpan-1) do |colIter|
            rowSpanStacks[colIter] = rowSpanStacks[currCol].intValue+rowSpan-1
          end
        end
        script = el.ownerDocument.createElement 'script'
        
        
        
        scriptContent = "
        TableLayout l = (TableLayout)parent.getLayout();
        TableLayout.Constraint c = l.createConstraint(#{currRow},#{currCol});
        c.setVerticalSpan(#{rowSpan});
        c.setHorizontalSpan(#{colSpan});
        parent.addComponent(c, self);
        "
        
        script.html(scriptContent)
        cellDiv.appendChild(script)
        
        tdChildren = td.childNodes.toArray Node[0]
        tdChildren.each do |n| 
          n.remove
          cellDiv.appendChild n
        end
        div.appendChild cellDiv
        currCol += 1
      end
      currRow += 1
    end
    
    findChildren('script', el).each do |scr|
      scr.remove
      div.appendChild(scr)
    end
    
    el.replaceWith div
    
    div.childNodes.each do |n| 
      if n.kind_of? Element
        preprocessElement Element(n)
      end
    end
  end
  
  def preprocessSelectElement(el:Element):void
      div = el.ownerDocument.createElement 'div'
      el.attributes.each {|att| div.attr att.getKey, att.getValue}
      if div.attr('class').length == 0 
          if div.attr('size').length != 0
              div.attr 'class', 'List'
          else
              div.attr 'class', 'ComboBox'
          end
          
      end
      script = el.ownerDocument.createElement 'script'
      scriptContent = StringBuilder.new
      scriptContent << "java.util.ArrayList opts = new java.util.ArrayList();\n"
      foundChild=false
      findChildren('option', el).each do |opt|
          foundChild=true
          tx = opt.text
          if opt.attr('i18n').length > 0
            tx = i18n "\"#{escape opt.attr 'i18n'}\"",
              "\"#{escapeHtml tx}\""
          else
            tx = "\"#{escapeHtml tx}\""
          end
          scriptContent << "opts.add(#{tx});\n"
      end
      if foundChild
        scriptContent << "self.setModel(new com.codename1.ui.list.DefaultListModel(opts));\n"
        script.appendChild(DataNode.new scriptContent.toString, "")
      
        div.appendChild script
      end
        
      
      if el.attr('model').length > 0 
          script = el.ownerDocument.createElement 'script'
          script.appendChild(DataNode.new "self.setModel(#{el.attr('model')});\n","")
          div.appendChild script
      elsif el.attr('data').length > 0
          script = el.ownerDocument.createElement 'script'
          script.appendChild(DataNode.new "self.setModel(new com.codename1.ui.list.DefaultListModel(#{el.attr('data')}));\n","")
          div.appendChild script
      end
      
      findChildren('script', el).each do |scr|
        scr.remove
        div.appendChild(scr)
      end
      el.replaceWith(div)
      
      
  end
  
  def preprocessElement(el:Element):void
    if 'table'.equals el.tagName
      preprocessTableElement el
    elsif 'select'.equals el.tagName
      preprocessSelectElement el
    elsif 'textarea'.equals el.tagName
      preprocessTextAreaElement el
    elsif 'tabs'.equals el.tagName or el.attr('class').endsWith 'Tabs'
      self.preprocessTabsElement el
    else
      el.childNodes.each do |n| 
        if n.kind_of? Element
          preprocessElement Element(n)
        end
      end
    end
    
    
  end
  
  
  def preprocessI18n(el:Element):void
    i18n el
    el.children.each {|child| preprocessI18n child}
  end
  
  # END PREPROCESSING ##########################################################
  
  def findOne(tagName:String, root:Element):Element
    return root if tagName.equals root.tagName
    root.childNodes.each do |node|
      if node.kind_of? Element
        el = Element(node)
        return el if tagName.equals el.tagName
      end
    end
    root.childNodes.each do |node|
      if node.kind_of? Element
        el = Element(node)
        res = findOne tagName, el
        return res if res
      end
    end
    
    nil
  end
  
  def findChildren(tagName:String, root:Element):Element[]
    out = []
    root.childNodes.each do |node|
      out.add node if node.kind_of? Element and 
          tagName.equals Element(node).tagName
    end
    out.toArray Element[0]
  end
  
  def buildClass(input:InputStream):String
    doc = Jsoup.parse(input, 'UTF-8', '/')
    preprocessDom doc
    output = StringBuilder.new
    writeHeader(output, doc)
    writeConstructor(output, doc)
    writeUIBuilder(output, doc)
    writeFooter(output)
    output.toString
  end
  
  def writeHeader(output:StringBuilder, doc:Document):void
    
    output << "/* THIS FILE IS AUTOMATICALLY GENERATED-- DO NOT MODIFY IT*/\n"<<
      "package #{getPackage};\n" << 
      getImports(doc) << 
      "import com.codename1.ui.*;\n" <<
      "import com.codename1.ui.layouts.*;\n" <<
      "import com.codename1.ui.table.*;\n" <<
      "import com.codename1.ui.util.*;\n" <<
      "class #{getSimpleClassName} {\n" <<
      "private Container rootContainer;\n" <<
      "private Resources resources;\n" <<
      "public Container getRoot(){ if (rootContainer==null){ 
        try {rootContainer=buildUI();} catch (Exception ex){ex.printStackTrace();throw new RuntimeException(ex.getMessage());}} return rootContainer;}\n" <<
      "private java.util.Map<String,Component> _nameIndex=new java.util.HashMap<String,Component>();\n" <<
      "public Component get(String name){ getRoot(); return _nameIndex.get(name);}\n"
  end
  
  
  
  def getImports(doc:Document):String
    out = StringBuilder.new
    doc.head.getElementsByTag('script').each do |script|
      out << script.html
    end
    out.toString
  end
  
  def writeFooter(output:StringBuilder):void
    output << tailBuffer.toString
    output << "}"
  end
  
  def getPackage:String
    @className.substring(0,@className.lastIndexOf('.'))
  end
  
  def getSimpleClassName:String
    if @className.indexOf('.') == -1
      @className
    else
      @className.substring(@className.lastIndexOf('.')+1)
    end
  end
  
  def writeUIBuilder(output:StringBuilder, doc:Document):void
    output << "private Container buildUI() throws Exception {\n"
    @varCounter=0
    writeNode(output, nil, 'root', doc.body)
    output << "return root;\n}\n"
  end
  
  def writeConstructor(output:StringBuilder, doc:Document):void
    methodBuilder = StringBuilder.new
    methodBuilder << "public #{getSimpleClassName}(java.util.Map context){\n"
    prefix = StringBuilder.new
    
    doc.getElementsByAttribute("attributes").each do |el|
      atts = el.attr('attributes').split(';')
      atts.each do |att|
        att = att.trim
        type = att.substring(0, att.indexOf(' '))
        key = att.substring(att.lastIndexOf(' ')+1)
        prefix << "private #{att};\n"
        methodBuilder << "#{key} = (#{type})context.get(\"#{key}\");\n"
      end
      
    end
    methodBuilder << "for (Object o : context.values()){ if (o instanceof Resources) resources=(Resources)o;}\n"
    methodBuilder << "}\n"
    
    output << prefix << methodBuilder
  end
  
  def writeLayout(output:StringBuilder, varName:String, el:Element):void
    
    layoutClass = getLayoutClass(el)
    
    output << "#{layoutClass} #{varName}Layout = " <<
      "new #{resolveLayoutDirective(el)};\n" << 
      "#{varName}.setLayout(#{varName}Layout);\n"
    
    
  end
  
  def getLayoutClass(layout:String):String
    layout = String(@@LAYOUT_SHORTCUTS[layout]) if @@LAYOUT_SHORTCUTS[layout]
    if (pos = layout.indexOf('(')) != -1 
      layout = layout.substring(0, pos)
      
    end
    if !layout || layout.length==0
      return 'FlowLayout'
    end
    layout = String(@@LAYOUT_SHORTCUTS[layout]) if @@LAYOUT_SHORTCUTS[layout]
    layout
  end
  
  def resolveLayoutDirective(el:Element):String
    layout = el.attr('layout')
    layout = String(@@LAYOUT_SHORTCUTS[layout]) if @@LAYOUT_SHORTCUTS[layout]
    
    if ( pos = layout.indexOf('(') != -1 and layout.length>0)
      layout
    else
      
      
      layoutClass = getLayoutClass el
      if "TableLayout".equals layoutClass
        rows = el.attr('rows')
        cols = el.attr('cols')
        
        if cols.length==0
          numRows=0
          numCols=0
          el.childNodes.each do |childNode|
            if childNode.kind_of? Element and "tr".equals Element(childNode).tagName
              numRows+=1
              colCounter=0
              Element(childNode).childNodes.each do |trChild|
                if trChild.kind_of? Element and "td".equals Element(trChild).tagName
                  colCounter+=1
                end
              end
              if colCounter>numCols
                numCols=colCounter
              end
            end
          end
          rows = "#{numRows}" if numRows>0
          cols = "#{numCols}" if numCols>0
          
        end
        rows = '1' if rows.length ==0
        cols = '1' if cols.length ==0
        return "#{layoutClass}(#{rows}, #{cols})"
      end
      getLayoutClass(el)+'()'
    end
  end
  
  def ucfirst(str:String)
    str.substring(0,1).toUpperCase+str.substring(1)
  end
  
  def writeNode(
    output:StringBuilder,
    parentVarName:String,
    node:Node
    ):void
    writeNode(output, parentVarName, nil, node)
  end
  
  def writeNode(
      output:StringBuilder, 
      parentVarName:String, 
      varName:String, 
      node:Node):void
  
    if !node.kind_of? Element
      return
    end
    el = Element(node)
    varName ||= "node#{@varCounter}"
    el.attr("java-varName", varName)
    @varCounter += 1
    
    parentClassName = Element(el.parentNode).attr('java-className')
    parentClassName = 'Container' if parentClassName.length == 0
    
    className = getElementUIClass(el)
    el.attr('java-className', className)
    output << "#{className} #{varName} = new #{className}();\n"
    writeLayout(output, varName, el) if isLayoutRequired el
    
    el.attributes.each do |attr|
      if attr.getKey.startsWith('data-')
        key = attr.getKey.substring(attr.getKey.indexOf('-')+1)
        output << "#{varName}.putClientProperty(\"#{key}\",#{quoteClientPropertyValue(attr.getValue)});\n"
      end
    end
    
    if el.attr('uiid').length>0
      output << "#{varName}.setUIID(\"#{el.attr('uiid')}\");\n"
    end
    
    if el.attr('name').length>0
      name = el.attr('name')
      output << "#{varName}.setName(\"#{name}\");\n" <<
        "_nameIndex.put(\"#{name}\", #{varName});\n"
      
      tailBuffer << "public #{className} get#{ucfirst(name)}(){
      return (#{className})get(\"#{name}\");
      }\n"
    end
    
    el.childNodes.each do |childNode|
      writeChild(
        output, 
        el, 
        childNode, 
        varName, 
        className, 
        parentVarName, 
        parentClassName)
    end
    writeAddToParent(output, parentVarName, varName, el) if parentVarName
    
  end
  
  def writeChildScript(
      output:StringBuilder, 
      el:Element, 
      scriptEl:Element, 
      varName:String, 
      className:String,
      parentVarName:String,
      parentClassName:String):void
    @scriptIDCounter ||= 1
    if "script".equals scriptEl.tagName
        
      parentVarName = "null" if !parentVarName or parentVarName.length==0
      output << "init#{@scriptIDCounter}_#{varName}(#{varName}, #{parentVarName});\n"
      tailBuffer << "private void init#{@scriptIDCounter}_#{varName}(#{className} self, #{parentClassName} parent){\n" <<
        scriptEl.data << scriptEl.text << "\n}\n"
      @scriptIDCounter += 1
    end
  end
  
  def writeChildImg(
      output:StringBuilder,
      el:Element,
      imgEl:Element,
      varName:String,
      className:String):void
    if "img".equals imgEl.tagName
      src = getImgSrc imgEl
      
      if ['Button','Label'].contains className
        output << "#{varName}.setIcon(#{src});\n"
        if imgEl.attr('align').length>0
          align = imgEl.attr 'align'
          if 'top'.equals align
            output << "#{varName}.setTextPosition(Component.BOTTOM);\n"
          elsif 'bottom'.equals align
            output << "#{varName}.setTextPosition(Component.TOP);\n"
          elsif 'left'.equals align
            output << "#{varName}.setTextPosition(Component.RIGHT);\n"
          elsif 'right'.equals align
            output << "#{varName}.setTextPosition(Component.LEFT);\n"
          end
        end
      else
        
        output << "#{varName}.addComponent(new Label(#{src}));\n"
      end
    end
  end
  
  def writeChild(
      output:StringBuilder,
      el:Element, 
      childNode:Node, 
      varName:String, 
      className:String,
      parentVarName:String,
      parentClassName:String):void
      
    if childNode.kind_of? Element
      childEl = Element(childNode)
      if "script".equals childEl.tagName
        writeChildScript(output,el,childEl,varName,className,parentVarName,parentClassName)
      elsif "img".equals childEl.tagName
        writeChildImg(output, el, childEl, varName, className)
      else
        writeNode output, varName, childNode
      end
    else
      if childNode.kind_of? TextNode
        tx = escape TextNode(childNode).text
        if el.attr('i18n').length > 0
          tx = i18n "\"#{escape el.attr 'i18n'}\"", 
            self.quoteClientPropertyValue(tx)
        else
          tx = "\"#{escape tx}\""
        end
        if ['Label','Button'].contains className and tx.trim.length>0
          output << "#{varName}.setText(#{tx});\n"
        elsif tx and tx.trim.length>0
          output << "#{varName}.addComponent(new Label(#{tx}));\n"
        end
      end
    end 
  end
  
  def escape(str:String):String
    str.replaceAll('\\\\', '\\\\').replaceAll('"','\\\\"')
  end
  
  def escapeHtml(str:String):String
      escape(str)
  end
  
  def getImgSrc(el:Element):String
    getImgSrc el.attr 'src'
    
  end
  
  def getImgSrc(srcStr:String):String
    if srcStr.startsWith 'res:'
      srcStr = srcStr.substring srcStr.indexOf(':')+1
      return "resources.getImage(\"#{escape(srcStr)}\")"
    elsif srcStr.startsWith 'jar:'
      srcStr = srcStr.substring srcStr.indexOf(':')+1
      return "Image.createImage(Display.getInstance().getResourceAsStream(null, \"#{escape(srcStr)}))\""
    else
      return srcStr
    end
  end
  
  def quoteClientPropertyValue(val:String):String
    if val.startsWith('java:')
      val.substring(val.indexOf(':')+1)
    elsif val.startsWith('string:')
      "\"#{val}\""
    elsif val.matches('^[0-9\.]+$')
      val
    elsif val.matches('^true|false$')
      val
    else
      "\"#{val}\""
    end
  end
  
  /**
   * Localizes all attributes of an HTML tag based on the values of corresponding
   * i18n:xxx attributes.
   */
  def i18n(el:Element):void
    newAtts = {}
    el.attributes.each do |att|
      if att.getKey.startsWith 'i18n:'
        attName = att.getKey.substring att.getKey.indexOf(':')+1
        defaultValue = quoteClientPropertyValue el.attr attName
        newAtts[attName] = i18n("\"#{escape att.getValue}\"", defaultValue)
      end
    end
    newAtts.entrySet.each do |e|
      el.attr "#{e.getKey}", "java:#{e.getValue}"
    end
    
    
  end
  
  /**
   * Returns Java code to localize a key with the provided default value.
   * @param key The key to localize.  If this is a raw string, it should include
   * the quotes.
   * @param defaultValue The default value.  If this is a raw string, it should
   * include the quotes.
   * @returns Java code to localize the string.
   */
  def i18n(key:String, defaultValue:String):String
    "com.codename1.ui.plaf.UIManager.getInstance().localize(#{key}, #{defaultValue})"
  end
  
  def getElementUIClass(el:Element):String
    return el.attr('class') if el.attr('class').length>0
    return String(@@UIClasses[el.tagName.toLowerCase]) if @@UIClasses[el.tagName.toLowerCase]
    if 'input'.equals el.tagName.toLowerCase
        type = el.attr 'type'
        return 'TextField' if 'text'.equals type
        return 'CheckBox' if 'checkbox'.equals type
        return 'RadioButton' if 'radio'.equals type
        return 'Slider' if 'range'.equals type
        return 'Calendar' if 'date'.equals type
    end
    'Container'
  end
  
  def writeAddToParent(
      output:StringBuilder,
      parentVarName:String, 
      varName:String, 
      el:Element):void
    return if ['tr,tbody,thead,tfoot'].contains el.tagName
    
    parentClass = getElementUIClass(Element(el.parentNode))
    parentLayoutClass = getElementUIClass(Element(el.parentNode))
    
    constraint = getLayoutConstraint(el)
    output << "if (#{varName}.getClientProperty(\"__CN1ML_NO_ADD__\") == null && #{parentVarName} != #{varName}.getParent()){\n"
    if !constraint
      output << "#{parentVarName}.addComponent(#{varName});\n"
    else
      output << "#{parentVarName}.addComponent(#{constraint}, #{varName});\n"
    end
    output << "}\n"
  end
    
  def getLayoutConstraint(el:Element):String
    constr = el.attr('layout-constraint') 
    constr = String(@@LAYOUT_CONSTRAINT_SHORTCUTS[constr]) if @@LAYOUT_CONSTRAINT_SHORTCUTS[constr]
    if 'td'.equals el.tagName and constr.length==0
      rowNum=0
      tr = Element(el.parentNode)
      table = Element(tr.parentNode)
      while !'table'.equals table.tagName
        table = Element(table.parentNode)
      end
      tbody = table
      table.childNodes.each do |tbodyChild|
        if tbodyChild.kind_of? Element and 'tbody'.equals Element(tbodyChild).tagName
          tbody = Element(tbodyChild)
          break
        end
      end
      
      tbody.childNodes.each do |trChild|
        break if trChild==tr
        if trChild.kind_of? Element and 'tr'.equals Element(trChild).tagName
          rowNum+=1
        end
      end
      
      colNum=0
      tr.childNodes.each do |tdChild|
        if tdChild.kind_of? Element and 'td'.equals Element(tdChild).tagName
          colNum+=1
          tdEl = Element(tdChild)
          if tdEl.attr('colspan').length>0
            colNum += Integer::parseInt(tdEl.attr('colspan'))-1
          end
        end
      end
      varName = table.attr('java-varName')
      constr = "((TableLayout)#{varName}.getLayout()).createConstraint(#{rowNum}, #{colNum})"
    end
    return constr if constr.length>0
    nil
  end
  
  def getLayoutClass(el:Element):String
    if ( el.attr('layout').length>0 )
      getLayoutClass(el.attr('layout'))
    else 
      
      if @@DEFAULT_LAYOUTS[el.tagName]
        String(@@DEFAULT_LAYOUTS[el.tagName])
      else
        'FlowLayout'
      end
    end
      
  end
  
  def isLayoutRequired(el:Element):boolean
    'Container'.equals getElementUIClass el
  end
  
  def tailBuffer : StringBuilder
    @tailBuffer ||= StringBuilder.new
  end
  
  
end