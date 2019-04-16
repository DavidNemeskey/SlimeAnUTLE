package data

import data.type.*
import java.lang.Error
import java.lang.Exception

object VariableFactory : Visitor {

    fun NameL2TypeL(names: List<SText>): List<SType> {
        val types = mutableListOf<SType>()
        for (n in names)
            types.add(SType[n()])
        return types
    }

    fun TypeL2NameL(types: List<SType>): List<SText> {
        val names = mutableListOf<SText>()
        for (t in types)
            names.add(SText(t.tag))
        return names
    }

    fun getEmptyVariableByTypeList(types: List<SType>): SVari {
        var tmp: SVari = when (types.last()) {
            SType["List"] -> throw Error("Last element of type list can not be a List")
            SType["Type"] -> SType["Vari"]
            SType["Iter"] -> throw Error("Last element of type list can not be a List")
            SType["Slot"] -> SSlot(SText())
            SType["Refe"] -> SRefe("", mutableListOf())
            SType["Text"] -> SText("")
            SType["Spec"] -> SSpec(SSpec.Char.COLON)
            SType["File"] -> SFile(mutableMapOf())
            SType["Temp"] -> STemp(mutableListOf())
            else -> SInst(types.last().tag)
        }
        val typescopy = types.toMutableList()
        val iter = typescopy[0] == SType["Iter"]
        if (iter)
            typescopy.removeAt(0)
        if (typescopy.size > 1) {
            for (i in (typescopy.size - 2)..0)
                if (typescopy[i] != SType["List"]) throw Exception("Inconsistent type.type List")
            for (i in (typescopy.size - 2)..0)
                tmp = tmp.visit(this, "BildIntoList")
        }
        return if (iter)
            (tmp as SList<*>).iter
        else
            tmp
    }


    override fun accept(h: SFile, mode: String): SList<SFile> = SList(mutableListOf())
    override fun accept(h: SSlot, mode: String): SList<SSlot> = SList(mutableListOf())
    override fun accept(h: SSpec, mode: String): SList<SSpec> = SList(mutableListOf())
    override fun accept(h: SType, mode: String): SList<SFile> = SList(mutableListOf())
    override fun accept(h: SInst, mode: String): SList<SInst> = SList(mutableListOf())
    override fun accept(h: STemp, mode: String): SList<STemp> = SList(mutableListOf())
    override fun accept(h: SRefe, mode: String): SList<SRefe> = SList(mutableListOf())
    override fun <T : SVari> accept(h: SList<T>, mode: String): SList<SList<T>> = SList(mutableListOf())
    override fun <T : SVari> accept(h: SList.SIter<T>, mode: String): SList<SList<T>> = SList(mutableListOf())
    override fun accept(h: SText, mode: String): SList<SText> = SList(mutableListOf())
}