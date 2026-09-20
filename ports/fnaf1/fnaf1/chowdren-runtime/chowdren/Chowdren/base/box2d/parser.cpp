#include "box2dext.h"
#include "parser.h"

using namespace Parser;

bool Parser::compare(char* buf, const char* cmp)
{
	while(parseType[*buf] == type_char)
	{
		if(*buf != *cmp) return false;
		buf++; cmp++;
	}
	return parseType[*cmp] != type_char;
}

bool Parser::nextElement(char* &buf)
{
	if(parseType[*buf] == type_delim || parseType[*buf] == type_start || parseType[*buf] == type_end)
	{
		buf++;
	}
	else if(parseType[*buf] == type_char)
	{
		while(parseType[*buf] == type_char) buf++;
	}
	else if(parseType[*buf] == type_number)
	{
		while(parseType[*buf] == type_number) buf++;
	}
	while(parseType[*buf] == type_space) buf++;
	if(parseType[*buf] == type_invalid) return false;
	return true;
}

bool Parser::parseVertices(char* &buf, b2Vec2* &dest, int &vCount, int minVerts)
{
	if(parseType[*buf] != type_start) return false;
	if(!nextElement(buf)) return false;
	char* buf2 = buf;
	int count = 0;
	while(true)
	{
		if(parseType[*buf2] == type_number) count++;
		else {return false;}
		if(!nextElement(buf2)) {return false;}
		if(parseType[*buf2] == type_end) break;
		else if(parseType[*buf2] != type_delim) {return false;}
		if(!nextElement(buf2)) {return false;}
	}
	if(count % 2 == 1 || count < minVerts*2) {return false;}

	dest = new b2Vec2[count/2];
	
	float* flt = (float*)dest;
	int i = 0;

	while(true)
	{
		if(!parseFloat(buf, flt[i++])) {return false;}
		if(parseType[*buf] == type_end) break;
		if(!nextElement(buf)) {return false;}
	}

	vCount = count/2;

	nextElement(buf);

	return true;
}

bool Parser::parseFloat(char* &buf, float &flt)
{
	if(sscanf(buf,"%f",&flt) == 0) return false;

	if(!nextElement(buf)) return false;

	return true;
}

bool Parser::parseInteger(char* &buf, int &val)
{
	if(sscanf(buf,"%i",&val) == 0) return false;

	if(!nextElement(buf)) return false;

	return true;
}

bool Parser::parseShape(char* &buf, b2ShapeDef* &def, Box2D* rdPtr)
{
	switch(*buf)
	{
	case 'c':
		{
			nextElement(buf);
			if(*buf != ':') return false;
			nextElement(buf);
			b2CircleDef* sd = new b2CircleDef;
			if(parseShapeCircle(buf,sd,rdPtr))
			{
				def = sd;
				return true;
			}
			else
			{
				delete sd;
				return false;
			}
		}

	case 'p':
		{
			nextElement(buf);
			if(*buf != ':') return false;
			nextElement(buf);
			b2PolygonDef* sd = new b2PolygonDef;
			if(parseShapePoly(buf,sd,rdPtr))
			{
				def = sd;
				return true;
			}
			else
			{
				delete sd;
				return false;
			}
		}

	case 'e':
		{
			nextElement(buf);
			if(*buf != ':') return false;
			nextElement(buf);
			b2EdgeChainDef* sd = new b2EdgeChainDef;
			if(parseShapeEdge(buf,sd,rdPtr))
			{
				def = sd;
				return true;
			}
			else
			{
				delete sd;
				return false;
			}
		}
	}

	return false;
}

bool Parser::parseShapeDefault(char* &buf, b2ShapeDef* def, Box2D* rdPtr)
{
	switch(*buf)
	{
	case 'e':
		if(compare(buf,"e") || compare(buf,"elasticity"))
		{
			if(!nextElement(buf)) return false;
			if(*buf != '=') return false;
			if(!nextElement(buf)) return false;
			if(!parseFloat(buf,def->restitution)) return false;
		}
		else
		{
			return false;
		}
		return true;

	case 'd':
		if(compare(buf,"d") || compare(buf,"density"))
		{
			if(!nextElement(buf)) return false;
			if(*buf != '=') return false;
			if(!nextElement(buf)) return false;
			if(!parseFloat(buf,def->density)) return false;
		}
		else
		{
			return false;
		}
		return true;

	case 'f':
		if(compare(buf,"f") || compare(buf,"friction"))
		{
			if(!nextElement(buf)) return false;
			if(*buf != '=') return false;
			if(!nextElement(buf)) return false;
			if(!parseFloat(buf,def->friction)) return false;
		}
		else
		{
			return false;
		}
		return true;

	case 'c':
		if(compare(buf,"cb") || compare(buf,"category") || compare(buf,"categorybits"))
		{
			if(!nextElement(buf)) return false;
			if(*buf != '=') return false;
			if(!nextElement(buf)) return false;
			int val;
			if(!parseInteger(buf,val)) return false;
			def->filter.categoryBits = val;
		}
		else if(compare(buf,"ct") || compare(buf,"colltype") || compare(buf,"collisiontype"))
		{
			if(!nextElement(buf)) return false;
			if(*buf != '=') return false;
			if(!nextElement(buf)) return false;
			int val;
			if(!parseInteger(buf,val)) return false;
			def->userData.collType = val;
		}
		else
		{
			return false;
		}
		return true;

	case 'm':
		if(compare(buf,"mb") || compare(buf,"mask") || compare(buf,"maskbits"))
		{
			if(!nextElement(buf)) return false;
			if(*buf != '=') return false;
			if(!nextElement(buf)) return false;
			int val;
			if(!parseInteger(buf,val)) return false;
			def->filter.maskBits = val;
		}
		else
		{
			return false;
		}
		return true;

	case 'g':
		if(compare(buf,"gi") || compare(buf,"groupindex"))
		{
			if(!nextElement(buf)) return false;
			if(*buf != '=') return false;
			if(!nextElement(buf)) return false;
			int val;
			if(!parseInteger(buf,val)) return false;
			def->filter.groupIndex = val;
		}
		else
		{
			return false;
		}
		return true;

	case 's':
		if(compare(buf,"s") || compare(buf,"sensor"))
		{
			if(!nextElement(buf)) return false;
			def->isSensor = true;
		}
		else
		{
			return false;
		}
		return true;

	default:
		return false;
	}
}

bool Parser::parseShapeCircle(char* &buf, b2CircleDef* def, Box2D* rdPtr)
{
	if(parseType[*buf] != type_start) return false;
	if(!nextElement(buf)) return false;

	while(true)
	{
		if(parseType[*buf] == type_end) break;
		if(parseType[*buf] != type_char) return false;
		switch(*buf)
		{
		case 'p':
			if(compare(buf,"p") || compare(buf,"pos") || compare(buf,"position"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->localPosition.x)) return false;
				if(*buf != ',') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->localPosition.y)) return false;
				def->localPosition *= 1.0f/rdPtr->scale;
			}
			else
			{
				return false;
			}
			break;

		case 'r':
			if(compare(buf,"r") || compare(buf,"radius"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->radius)) return false;
				def->radius /= rdPtr->scale;
			}
			else
			{
				return false;
			}
			break;

		default:
			if(!parseShapeDefault(buf,def,rdPtr)) return false;
			break;
		}
	}
	nextElement(buf);
	return true;
}

bool Parser::parseShapePoly(char* &buf, b2PolygonDef* def, Box2D* rdPtr)
{
	if(parseType[*buf] != type_start) return false;
	if(!nextElement(buf)) return false;

	while(true)
	{
		if(parseType[*buf] == type_end) break;
		if(parseType[*buf] != type_char) return false;
		switch(*buf)
		{
		case 'v':
			if(compare(buf,"v") || compare(buf,"verts") || compare(buf,"vertices"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				delete [] def->vertices;
				if(!parseVertices(buf,def->vertices,def->vertexCount,3)) return false;
				def->vertexMax = def->vertexCount;
				for(int i = 0; i < def->vertexMax; i++)
					def->vertices[i] *= 1.0f/rdPtr->scale;
			}
			else
			{
				return false;
			}
			break;

		default:
			if(!parseShapeDefault(buf,def,rdPtr)) return false;
			break;
		}
	}
	nextElement(buf);
	return true;
}

bool Parser::parseShapeEdge(char* &buf, b2EdgeChainDef* def, Box2D* rdPtr)
{
	if(parseType[*buf] != type_start) return false;
	if(!nextElement(buf)) return false;

	while(true)
	{
		if(parseType[*buf] == type_end) break;
		if(parseType[*buf] != type_char) return false;
		switch(*buf)
		{
		case 'v':
			if(compare(buf,"v") || compare(buf,"verts") || compare(buf,"vertices"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				delete [] def->vertices;
				if(!parseVertices(buf,def->vertices,def->vertexCount,3)) return false;
				def->vertexMax = def->vertexCount;
				for(int i = 0; i < def->vertexMax; i++)
					def->vertices[i] *= 1.0f/rdPtr->scale;
			}
			else
			{
				return false;
			}
			break;

		case 'l':
		case 'i':
			if(compare(buf,"l") || compare(buf,"loop") || compare(buf,"looped") || compare(buf,"islooped"))
			{
				if(!nextElement(buf)) return false;
				def->isALoop = true;
			}
			else
			{
				return false;
			}
			break;

		default:
			if(!parseShapeDefault(buf,def,rdPtr)) return false;
			break;
		}
	}
	nextElement(buf);
	return true;
}

bool Parser::parseBodySub(char* &buf, b2BodyDef* def, Box2D* rdPtr)
{
	if(parseType[*buf] != type_start) return false;
	if(!nextElement(buf)) return false;

	b2BodyDef* def2 = new b2BodyDef;

	while(true)
	{
		if(parseType[*buf] == type_end) break;
		if(parseType[*buf] != type_char) return false;
		switch(*buf)
		{
		case 'm':
			if(compare(buf,"m") || compare(buf,"md") || compare(buf,"mass") || compare(buf,"massdata"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->massData.mass)) return false;
				if(*buf != ',') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->massData.I)) return false;
				if(*buf != ',') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->massData.center.x)) return false;
				if(*buf != ',') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->massData.center.y)) return false;
				def->massData.center *= 1.0f/rdPtr->scale;
			}
			else
			{
				return false;
			}
			break;

		case 'l':
			if(compare(buf,"ld") || compare(buf,"lineardamping"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->linearDamping)) return false;
			}
			else
			{
				return false;
			}
			break;

		case 'a':
			if(compare(buf,"ad") || compare(buf,"angulardamping"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				if(!parseFloat(buf,def->angularDamping)) return false;
			}
			else
			{
				return false;
			}
			break;

		case 's':
			if(compare(buf,"sl") || compare(buf,"sleep"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				
				if(compare(buf,"d") || compare(buf,"disable"))
				{
					def->allowSleep = false;
				}
				else if (compare(buf,"t") || compare(buf,"s") || compare(buf,"sleeping") || compare(buf,"true"))
				{
					def->isSleeping = true;
				}
				else
				{
					return false;
				}

				if(!nextElement(buf)) return false;
			}
			else if(compare(buf,"s") || compare(buf,"sh") || compare(buf,"shape"))
			{
				if(!nextElement(buf)) return false;
				if(*buf != '=') return false;
				if(!nextElement(buf)) return false;
				b2ShapeDef* sd;
				if(!parseShape(buf,sd,rdPtr)) return false;

				b2ShapeDef** newList = new b2ShapeDef*[def->numShapes+1];
				memcpy(newList,def->shapes,def->numShapes*sizeof(b2ShapeDef*));
				newList[def->numShapes] = sd;
				def->shapes = newList;
				def->numShapes++;
			}
			else
			{
				return false;
			}
			break;

		case 'f':
			if(compare(buf,"f") || compare(buf,"fixedrot") || compare(buf,"fixedrotation"))
			{
				if(!nextElement(buf)) return false;
				def->fixedRotation = true;
			}
			else
			{
				return false;
			}
			break;

		case 'b':
			if(compare(buf,"b") || compare(buf,"bullet"))
			{
				if(!nextElement(buf)) return false;
				def->isBullet = true;
			}
			else
			{
				return false;
			}
			break;

		default:
			return false;
		}
	}
	nextElement(buf);
	return true;
}

bool Parser::parseBody(char* &buf, b2BodyDef* &def, Box2D* rdPtr)
{
	b2BodyDef* def2 = new b2BodyDef;

	if(parseBodySub(buf,def2,rdPtr))
	{
		def = def2;
		return true;
	}
	else
	{
		delete def2;
		def = NULL;
		return false;
	}
}

