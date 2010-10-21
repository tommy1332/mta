--[[ Vehikel Modifikationen (carmods)

	Beschreibung: 
		Dieses Modul ersetzt die original vorhandenen Vehikel mit anderen Modellen

]]

carmods = 
{

}

function carmods.onStart()
	log('carmods.onStart')
	carmods.replaceCars()
end

function carmods.onStop()
	log('carmods.onStop')
end

base.addModule('carmods', carmods.onStart, carmods.onStop)

function carmods.replaceCars() 
	--Washington
	txd = engineLoadTXD ( "data/carmods/peren.txd" )
	engineImportTXD ( txd, 422)
	dff = engineLoadDFF ( "data/carmods/peren.dff", 422)
	engineReplaceModel ( dff, 422)
	--Audi R8
	txd = engineLoadTXD ( "data/carmods/bullet.txd" )
	engineImportTXD ( txd, 507)
	txd1 = engineLoadTXD ( "data/carmods/bullet1.txd" )
	engineImportTXD ( txd1, 507)
	txd2 = engineLoadTXD ( "data/carmods/bullet2.txd" )
	engineImportTXD ( txd2, 507)
	txd3 = engineLoadTXD ( "data/carmods/bullet3.txd" )
	engineImportTXD ( txd3, 507)
	txd4 = engineLoadTXD ( "data/carmods/bullet4.txd" )
	engineImportTXD ( txd4, 507)
	dff = engineLoadDFF ( "data/carmods/bullet.dff", 507)
	engineReplaceModel ( dff, 507)
	--Adminauto Lambo
	 txd = engineLoadTXD ( "data/carmods/infernus.txd" )
	engineImportTXD ( txd, 506)
	txd1 = engineLoadTXD ( "data/carmods/infernus1.txd" )
	engineImportTXD ( txd1, 506)
	txd2 = engineLoadTXD ( "data/carmods/infernus2.txd" )
	engineImportTXD ( txd2, 506)
	txd3 = engineLoadTXD ( "data/carmods/infernus3.txd" )
	engineImportTXD ( txd3, 506)
	txd4 = engineLoadTXD ( "data/carmods/infernus4.txd" )
	engineImportTXD ( txd4, 506)
	dff = engineLoadDFF ( "data/carmods/infernus.dff", 506)
	engineReplaceModel ( dff, 506)
end