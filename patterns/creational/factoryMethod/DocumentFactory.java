public abstract class DocumentFactory{
	public abstract Document createDocument();

	public void printDocument(){
		Document doc = createDocument();
		doc.print();
	}

}
