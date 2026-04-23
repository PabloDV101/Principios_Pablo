public class Main{
public static void main (String[] args){
DocumentFactory factory;
factory = new PdfFactory();
factory.printDocument();

factory = new WordFactory();
factory.printDocument();

factory = new PPFactory();
factory.printDocument();
}

}
