local MyVector = class("MyVector")
--����һ��MyVector
function MyVector:ctor()
	self._data = {}
end
--ĩβ����һ������
function MyVector:push_back(val)
	table.insert(self._data,table.getn(self._data) + 1,val)	
end
--��ȡָ��λ�õ�����
function MyVector:at(i)
	return self._data[i]
end
--ɾ������
function MyVector:erase(val)
	local i = 1 
    while self._data[i] do 
		if self._data[i] == val then 
			table.remove(self._data,i) 
		else 
			i = i + 1 
		end 
	end 
end
--��������,������������λ�õ��±�
function MyVector:find(val)
	local i = 1 
    while self._data[i] do 
		if self._data[i] == val then 
		   return i;
		else 
			i = i + 1 
		end 
	end 
end
--���Vector��ǰ���ݸ���
function MyVector:size()
	return table.getn(self._data)
end
--���Vector
function MyVector:clear()
	self._data = {};
end
return MyVector;