package ar.edu.unq.uis.domino.viewmodel

import org.uqbar.commons.model.annotations.Observable
import org.eclipse.xtend.lib.annotations.Accessors
import ar.edu.unq.uis.domino.repo.Repositories
import org.uqbar.commons.model.utils.ObservableUtils
import ar.edu.unq.uis.domino.model.Pedido

@Accessors
@Observable
class PedidosAbiertosViewModel {
	
	Pedido pedidoSeleccionado
	
	def getPedidos(){
		Repositories.getPedidos.allInstances
	}
	
	def eliminarSeleccionado() {
		if (pedidoSeleccionado == null){
			return
		}
		Repositories.getPedidos.delete(pedidoSeleccionado)
		pedidoSeleccionado = null
		refresh
	}
	
	def refresh(){
		ObservableUtils.firePropertyChanged(this, "pedidos", getPedidos)
	}
	
}