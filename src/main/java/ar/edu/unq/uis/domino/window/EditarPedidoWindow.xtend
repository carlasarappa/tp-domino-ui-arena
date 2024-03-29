package ar.edu.unq.uis.domino.window

import ar.edu.unq.uis.domino.appmodel.PedidosAbiertosAppModel
import org.uqbar.arena.windows.SimpleWindow
import ar.edu.unq.uis.runnable.DominoApplication
import org.uqbar.arena.widgets.Panel
import org.uqbar.arena.widgets.Label
import org.uqbar.arena.layout.HorizontalLayout
import org.uqbar.arena.layout.VerticalLayout
import org.uqbar.arena.widgets.tables.Table
import ar.edu.unq.uis.domino.model.Pedido
import static extension org.uqbar.arena.xtend.ArenaXtendExtensions.*
import org.uqbar.arena.widgets.tables.Column
import ar.edu.unq.uis.domino.model.Estado
import org.uqbar.arena.widgets.Button
import org.uqbar.arena.windows.Dialog
import org.uqbar.arena.bindings.PropertyAdapter
import org.uqbar.arena.widgets.Selector
import org.uqbar.arena.layout.ColumnLayout
import ar.edu.unq.uis.domino.model.Pizza
import ar.edu.unq.uis.domino.model.Plato
import org.uqbar.arena.widgets.TextBox
import org.uqbar.arena.windows.WindowOwner
import ar.edu.unq.uis.domino.appmodel.PedidoAppModel
import org.uqbar.arena.aop.windows.TransactionalDialog
import org.uqbar.arena.windows.ErrorsPanel
import org.uqbar.arena.bindings.NotNullObservable
import org.uqbar.arena.bindings.DateTransformer
import ar.edu.unq.uis.domino.adapters.MoneyAdapter
import ar.edu.unq.uis.domino.adapters.FechaYHoraAdapter

class EditarPedidoWindow extends TransactionalDialog<PedidoAppModel>{
	
	new(WindowOwner owner, Pedido pedido) {
		super(owner, createViewModel(pedido))
		modelObject.calcular
	}
	
	static def createViewModel(Pedido pedido){
		val model = new PedidoAppModel()
		model.elemento = pedido
		return model
		
	}
		
	override def createMainTemplate(Panel mainPanel) {
		title = "Editar pedido"		
		super.createMainTemplate(mainPanel)
	}
	
	override ErrorsPanel createErrorsPanel(Panel mainPanel) {
		return new ErrorsPanel(mainPanel, this.getTaskDescription(), 2);
	}
	
	override protected createFormPanel(Panel mainPanel) {
		val panelEstado = new Panel(mainPanel)
		panelEstado.layout = new ColumnLayout(2)
		
		new Label(panelEstado).text = "Estado"
		
		new Selector(panelEstado) => [
            value <=> "elemento.estado"
            enabled <=> "elemento.estado.abierto"
            
            val bindingItems = items <=> "elemento.formaDeEnvio.estadosPosibles"
     		bindingItems.adapter = new PropertyAdapter(typeof(Estado), "nombre")
            width = 220
            height = 220
		]	
		
		val tablaConBotonera = new Panel(mainPanel)
		tablaConBotonera.layout = new HorizontalLayout()
		createResultsGrid(tablaConBotonera)
		val botonera = new Panel(tablaConBotonera)
		botonera.layout = new VerticalLayout()
		crearBotonera(botonera)
		aclaracionesPanel(mainPanel)
		datosCliente(mainPanel)
		
	}
	
	def crearBotonera(Panel panel) {
		new Button(panel) => [
			caption = "Agregar"
			onClick([| abrirAgregarPlato])
			visible <=> "elemento.estado.abierto"
		]
		
		val elementSelected = new NotNullObservable("platoSeleccionado")

		new Button(panel) => [
			caption = "Editar"
			onClick([| abrirEdicionPlato])
			visible <=> "elemento.estado.abierto"
			bindEnabled(elementSelected)	
		]	
		
		new Button(panel) => [
			caption = "Eliminar"
			onClick([| modelObject.eliminarSeleccionado])	
			visible <=> "elemento.estado.abierto"
			bindEnabled(elementSelected)
		]

	}
	
	
	def protected createResultsGrid(Panel mainPanel) {
		val table = new Table<Plato>(mainPanel, typeof(Plato)) => [
			items <=> "platos"
			value <=> "platoSeleccionado"
			numberVisibleRows = 12
		]
		
		new Column<Plato>(table) => [
			title = "Nombre"
			fixedSize = 300
			bindContentsToProperty("pizzaBase.nombre")
		]

		new Column<Plato>(table) => [
			title = "Tamaño"
			fixedSize = 200
			alignRight
			bindContentsToProperty("tamanio")
		]
		
		new Column<Plato>(table) => [
			title = "Precio"
			fixedSize = 200
			alignRight
			bindContentsToProperty("precio").setTransformer(new MoneyAdapter())			
		]
	}
	
	def aclaracionesPanel(Panel panel){
		new Label(panel).text = "Aclaraciones"
		new TextBox(panel) => [
			enabled <=> "elemento.estado.abierto"
			value <=> "elemento.aclaraciones"
		    width = 800 
		]
		
	}
	def datosCliente(Panel panel){
		val columnas = new Panel(panel)
		columnas.layout = new ColumnLayout(2) 
		
		new Label(columnas).text = "Nombre: "

		new Label(columnas) => [
		    value <=> "elemento.cliente.nombre"
		]
		new Label(columnas).text = "Costo de envío: "

		new Label(columnas) => [
		    bindValueToProperty("elemento.formaDeEnvio.costoEnvio").setTransformer(new MoneyAdapter())
		]
		new Label(columnas).text = "Monto total: "

		new Label(columnas) => [
		    bindValueToProperty("monto").setTransformer(new MoneyAdapter())

		]
		new Label(columnas).text = "Fecha y hora: "

		new Label(columnas) => [
		    bindValueToProperty("elemento.fecha").setTransformer(new FechaYHoraAdapter())
		]
		
	}
	
	def void abrirEdicionPlato(){
		if (modelObject.platoSeleccionado == null){
			throw new RuntimeException("Se debe seleccionar un plato")
		}
		val window = new EditarPlatoWindow(this, modelObject.platoSeleccionado)
		window.onAccept[ | modelObject.calcular]
		window.open
	}
	
	def void abrirAgregarPlato(){
		val window = new AgregarPlatoWindow(this, modelObject.elemento)
		window.onAccept[ | modelObject.calcular ]
		window.open
	}
	
	

	override protected addActions(Panel actions){
		new Button(actions) => [
			caption = "Aceptar"
			onClick [|
				this.accept
			]	
		]

		new Button(actions) => [
			caption = "Cancelar"	
			onClick [|
				this.cancel
			]
		]
	}
	
	override executeTask() {
		modelObject.guardar
		super.executeTask()
	}

}

