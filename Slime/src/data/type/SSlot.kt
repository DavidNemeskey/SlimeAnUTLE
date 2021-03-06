package data.type

import data.*
import java.lang.Exception

class SSlot(val tag: SName, names: List<SName> = listOf()) : SVari("Slot", names), Visitor {

    var content: STemp? = null
    var owner: STemp? = null

    override fun listPaths(): SList<SList<SName>> = content?.listPaths() ?: SList()

    override fun copy(names: List<SName>): SSlot {
        val result = SSlot(tag, names)
        if (content != null)
            result.content = content?.copy()
        return result
    }

    override fun extend(divider: String): String = content?.extend() ?: "{$ ${tag()} $}"

    override fun plus(v: SVari, i: Int): SVari = v.accept(this, "@add")


    override fun get(path: SList<SName>): SVari =
        when {
            path.isEmpty() -> content ?: this
            else -> {
                val next = path[0]()
                path.removeAt(0)
                when (next) {
                    "names" -> names.toSList(owner = this).get(path)
                    "self" -> this.get(path)
                    "copy" -> copy().get(path)
                    "cont" -> content?.get(path) ?: throw Exception(
                        "no Template in slot: ${names.getOrNull(0) ?: "@nameless"}"
                    )
                    else -> throw  Exception("unknown keyword for slot: ${names.getOrNull(0) ?: "@nameless"}")
                }
            }
        }

    override fun delete(path: SList<SName>) {
        when {
            path.isEmpty() -> throw Exception(
                "path shouldn't be empty when deleting from Slot: ${names.getOrNull(0) ?: "@nameless"}"
            )
            path.size == 1 && path[0]() == "@content" -> {
                content = null
            }
            else -> {
                content?.delete(path) ?: throw Exception("Wrong variable name")
            }
        }
    }


    override fun accept(v: Visitor, mod: String): SVari = v.visit(this, mod)

    override fun visit(h: SSlot, mode: String): SVari =
        when (mode) {
            "@add" -> {
                this.content = STemp(mutableListOf(h)); owner ?: this
            }
            else -> throw Exception(
                "wrong variable or in wrong mode visiting Slot: ${names.getOrNull(0) ?: "@nameless"}"
            )
        }

    override fun visit(h: SSpec, mode: String): SVari = when (mode) {
        "@add" -> {
            this.content = STemp(mutableListOf(h)); owner ?: this
        }
        else -> throw Exception(
            "wrong variable or in wrong mode visiting Slot: ${names.getOrNull(0) ?: "@nameless"}"
        )
    }

    override fun visit(h: SType, mode: String): SVari =
        throw Exception("You can not add a Structure type into Slot ${names.getOrNull(0) ?: "@nameless"}")

    override fun visit(h: SInst, mode: String): SVari =
        throw Exception("You can not add a Structure Instance into Slot ${names.getOrNull(0) ?: "@nameless"}")

    override fun visit(h: STemp, mode: String): SVari =
        when (mode) {
            "@add" -> {
                this.content = h; owner ?: this
            }
            else -> throw Exception(
                "wrong variable or in wrong mode visiting Slot: ${names.getOrNull(0) ?: "@nameless"}"
            )
        }

    override fun visit(h: SText, mode: String): SVari = when (mode) {
        "@add" -> {
            this.content = STemp(mutableListOf(h)); owner ?: this
        }
        else -> throw Exception(
            "wrong variable or in wrong mode visiting Slot: ${names.getOrNull(0) ?: "@nameless"}"
        )
    }

    override fun visit(h: SName, mode: String): SVari = when (mode) {
        "@add" -> {
            this.content = STemp(mutableListOf(h)); owner ?: this
        }
        else -> throw Exception(
            "wrong variable or in wrong mode visiting Slot: ${names.getOrNull(0) ?: "@nameless"}"
        )
    }

    override fun visit(h: SRefe, mode: String): SVari = throw Exception("TODO")

    override fun <T : SVari> visit(h: SList<T>, mode: String): SVari =
        when (mode) {
            "@add" -> {
                if (h[0] is SName) {
                    addNames(h.filter { it is SName }.map { it as SName })
                    this
                } else
                    SList(h.map { owner?.copy()?.plus(it) ?: copy().plus(it) }.toMutableList())
            }
            else -> throw Exception(
                "wrong variable or in wrong mode visiting Slot: ${names.getOrNull(0) ?: "@nameless"}"
            )
        }

    override fun <T : SVari> visit(h: SList.SIter<T>, mode: String): SVari =
        when (mode) {
            "@add" -> {
                if (h.owner[0] is SName) {
                    addNames(h.owner.filter { it is SName }.map { it as SName })
                    this
                } else
                    SList(h.owner.map { owner?.copy()?.plus(it) ?: copy().plus(it) }.toMutableList()).iter
            }
            else -> throw Exception(
                "wrong variable or in wrong mode visiting Slot: ${names.getOrNull(0) ?: "@nameless"}"
            )
        }

    override fun visit(h: SFile, mode: String): SVari =
        throw Exception("You can not insert File int Slot: ${names.getOrNull(0) ?: "@nameless"}")
}