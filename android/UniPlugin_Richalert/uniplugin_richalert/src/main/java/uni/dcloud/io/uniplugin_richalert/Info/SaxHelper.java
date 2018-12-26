package uni.dcloud.io.uniplugin_richalert.Info;

import android.text.TextUtils;

import com.alibaba.fastjson.JSONObject;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import java.util.ArrayList;


public class SaxHelper extends DefaultHandler {
    private Person person;
    private ArrayList<Person> persons;
    //当前解析的元素标签
    private String tagName = null;

    /**
     * 当读取到文档开始标志是触发，通常在这里完成一些初始化操作
     */
    @Override
    public void startDocument() throws SAXException {
        this.persons = new ArrayList<Person>();
        //Log.i("SAX", "读取到文档头,开始解析xml");
    }


    /**
     * 读到一个开始标签时调用,第二个参数为标签名,最后一个参数为属性数组
     */
    @Override
    public void startElement(String uri, String localName, String qName,
                             Attributes attributes) throws SAXException {
        this.person = new Person();
        this.persons.add(this.person);
        person.label = localName;
        if(attributes != null && attributes.getLength() > 0) {
            JSONObject attr = new JSONObject();
            for(int i=0;i<attributes.getLength();i++) {
                attr.put(attributes.getLocalName(i), attributes.getValue(i));
            }
            person.attribute = attr;
        }
        this.tagName = localName;
    }

    /**
     * 读到到内容,第一个参数为字符串内容,后面依次为起始位置与长度
     */
    @Override
    public void characters(char[] ch, int start, int length) throws SAXException {
        //判断当前标签是否有效
        String data = new String(ch, start, length);
        if (this.tagName != null) {
            if(TextUtils.isEmpty(this.person.content)) {
                this.person.content = data;
            } else {
                this.person.content = this.person.content + data;
            }
        } else {
            //补充遗漏text
            this.person = new Person();
            this.persons.add(this.person);
            person.label = "text";
            person.content = data;
            person = null;
        }

    }

    /**
     * 处理元素结束时触发,这里将对象添加到结合中
     */
    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException {
        this.person = null;
        //Log.i("SAX", "处理person元素结束~");
        this.tagName = null;
    }

    /**
     * 读取到文档结尾时触发，
     */
    @Override
    public void endDocument() throws SAXException {
        super.endDocument();
        //Log.i("SAX", "读取到文档尾,xml解析结束");
    }

    //获取persons集合
    public ArrayList<Person> getPersons() {
        return persons;
    }

}
