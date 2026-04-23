public class AdaptadorAmericanoAEuropeo implements EnchufeEuropeo{

	private EnchufeAmericano enchufeAmericano;

	public AdaptadorAmericanoAEuropeo(EnchufeAmericano enchufeAmericano){
	this.enchufeAmericano=enchufeAmericano;

	}
	@Override
	public void conectar(){
		enchufeAmericano.plugIn();
	}
}
