%module jieba_fast_functions_py3



%{

#include <math.h>
#include <float.h>
#include <stdlib.h>


int _calc(PyObject* FREQ, PyObject* sentence,PyObject* DAG, PyObject * route, double total)
{
    const Py_ssize_t N = PySequence_Size(sentence);
    const double logtotal = log(total);
    double max_freq, fq, fq_2, fq_last;
    Py_ssize_t max_x, idx,i, t_list_len, x;
    PyObject* t_list, *slice_of_sentence, *o_freq, *t_tuple, *tuple_last;
    PyObject* temp_tuple = PyTuple_New(2);

    PyTuple_SetItem(temp_tuple, 0, PyInt_FromLong(0l));
    PyTuple_SetItem(temp_tuple, 1, PyInt_FromLong(0l));
    PyDict_SetItem(route, PyInt_FromLong((long)N), temp_tuple);

    for(idx = N - 1; idx >= 0 ;idx--)
    {
        max_freq = INT_MIN;
        max_x = 0;
        t_list = PyDict_GetItem(DAG, PyInt_FromLong((long)idx));
        t_list_len = PyList_Size(t_list);
        for(i = 0; i < t_list_len; i++)
        {
            fq = 1;
            x = PyInt_AsLong(PyList_GetItem(t_list, i));
            slice_of_sentence = PySequence_GetSlice(sentence, idx, x+1);
            o_freq = PyDict_GetItem(FREQ, slice_of_sentence);
            if (o_freq != NULL)
            {
                fq = PyInt_AsLong(o_freq);
                if (fq == 0) fq = 1;
            }
            t_tuple = PyDict_GetItem(route, PyInt_FromLong((long)x + 1));
            fq_2 = PyFloat_AsDouble(PyTuple_GetItem(t_tuple, 0));
            fq_last = log((double)fq) - logtotal + fq_2;
            if(fq_last > max_freq)
            {
                max_freq = fq_last;
                max_x = x;
            }
            if(slice_of_sentence!=NULL)
                Py_DecRef(slice_of_sentence);
        }
        tuple_last = PyTuple_New(2);
        PyTuple_SetItem(tuple_last, 0, PyFloat_FromDouble(max_freq));
        PyTuple_SetItem(tuple_last, 1, PyInt_FromLong((long)max_x));
        PyDict_SetItem(route, PyInt_FromLong((long)idx), tuple_last);
    }
    return 1;
}

int _get_DAG(PyObject* DAG, PyObject* FREQ, PyObject* sentence)
{
    const Py_ssize_t N = PySequence_Size(sentence);
    PyObject *tmplist, *frag;
    Py_ssize_t i, k;
    for(k = 0; k< N;k++)
    {
        tmplist = PyList_New(0);
        i = k;
        frag = PySequence_GetItem(sentence, k);
        while(i < N && PyDict_Contains(FREQ, frag))
        {
            if(PyInt_AsLong(PyDict_GetItem(FREQ, frag)))
            {
                PyList_Append(tmplist, PyInt_FromLong((long)i));
            }
            i += 1;
            frag = PySequence_GetSlice(sentence, k ,i+1);
        }
        if (PyList_Size(tmplist) == 0)
            PyList_Append(tmplist, PyInt_FromLong((long)k));
        PyDict_SetItem(DAG, PyInt_FromLong((long)k), tmplist);
    }
    return 1;
}

int _get_DAG_and_calc(PyObject* FREQ, PyObject* sentence, PyObject * route, double total)
{
    const Py_ssize_t N = PySequence_Size(sentence);
    Py_ssize_t (*DAG)[20] = malloc(sizeof(Py_ssize_t)*20*N);
    Py_ssize_t *points = (Py_ssize_t*)malloc(sizeof(Py_ssize_t)*N);
    Py_ssize_t k, i, idx, max_x, t_list_len, fq, x;
    PyObject *frag, *t_f, *slice_of_sentence, *o_freq;
    double (*_route)[2] = malloc(sizeof(double)*2*(N+1));
    double logtotal = log(total);
    double max_freq = INT_MIN;
    double fq_2, fq_last;

    _route[N][0] = 0;
    _route[N][1] = 0;

    for(i = 0; i < N; i++)
        points[i] = 0;

    for(k = 0; k< N;k++)
    {
        i = k;
        frag = PySequence_GetItem(sentence, k);
        while(i < N && (t_f = PyDict_GetItem(FREQ, frag)) && (points[k] < 12))
        {
            if(PyInt_AsLong(t_f))
            {
                DAG[k][points[k]] = i;
                points[k] ++;
            }
            i += 1;
            if(frag!=NULL)
                Py_DecRef(frag);
            frag = PySequence_GetSlice(sentence, k ,i + 1);
        }
        if(frag!=NULL)
            Py_DecRef(frag);
        if(points[k] == 0)
        {
            DAG[k][0] = k;
            points[k] = 1;
        }
    }


    for(idx = N - 1; idx >= 0 ;idx--)
    {
        max_freq = INT_MIN;
        max_x = 0;
        t_list_len = points[idx];
        for(i = 0; i < t_list_len; i++)
        {
            fq = 1;
            x = DAG[idx][i];
            slice_of_sentence = PySequence_GetSlice(sentence, idx, x + 1);
            o_freq = PyDict_GetItem(FREQ, slice_of_sentence);
            if (o_freq != NULL)
            {
                fq = PyInt_AsLong(o_freq);
                if (fq == 0) fq = 1;
            }
            fq_2 = _route[x + 1][0];
            fq_last = log((double)fq) - logtotal + fq_2;
            if(fq_last > max_freq)
            {
                max_freq = fq_last;
                max_x = x;
            }
            if(slice_of_sentence!=NULL)
                Py_DecRef(slice_of_sentence);
        }
        _route[idx][0] = max_freq;
        _route[idx][1] = (double)max_x;
    }
    for(i = 0; i <= N; i++)
    {
        PyList_Append(route, PyInt_FromLong((long)_route[i][1]));
    }
    free(DAG);
    free(points);
    free(_route);
    return 1;
}

#define MIN_FLOAT -3.14e100
PyObject* _viterbi(PyObject* obs, PyObject* _states, PyObject* start_p, PyObject* trans_p, PyObject* emip_p)
{
    const Py_ssize_t obs_len = PySequence_Size(obs);
    const char* PrevStatus_str[22];
    const int states_num = 4;
    PyObject *item, *t_dict, *t_obs, *res_tuple, *t_list, *ttemp;
    Py_ssize_t i, j;
    double t_double, t_double_2, em_p, max_prob, prob;
    double (*V)[22] = malloc(sizeof(double)*obs_len*22);
    char * states = PyUnicode_AsUTF8(_states);
    char (*path)[22] = malloc(sizeof(char)*obs_len*22);
    char y, best_state, y0, now_state;
    int p;


    PyObject* emip_p_dict[4];
    PyObject* trans_p_dict[22][2];
    PyObject* py_states[4];

    for(i=0;i<states_num;i++)
        py_states[i] = PyUnicode_FromStringAndSize(states + i, 1);

    PrevStatus_str['B'-'B'] = "ES";
    PrevStatus_str['M'-'B'] = "MB";
    PrevStatus_str['S'-'B'] = "SE";
    PrevStatus_str['E'-'B'] = "BM";

    emip_p_dict[0] = PyDict_GetItem(emip_p, py_states[0]);
    emip_p_dict[1] = PyDict_GetItem(emip_p, py_states[1]);
    emip_p_dict[2] = PyDict_GetItem(emip_p, py_states[2]);
    emip_p_dict[3] = PyDict_GetItem(emip_p, py_states[3]);

    trans_p_dict['B'-'B'][0] = PyDict_GetItem(trans_p, py_states[2]);
    trans_p_dict['B'-'B'][1] = PyDict_GetItem(trans_p, py_states[3]);
    trans_p_dict['M'-'B'][0] = PyDict_GetItem(trans_p, py_states[1]);
    trans_p_dict['M'-'B'][1] = PyDict_GetItem(trans_p, py_states[0]);
    trans_p_dict['E'-'B'][0] = PyDict_GetItem(trans_p, py_states[0]);
    trans_p_dict['E'-'B'][1] = PyDict_GetItem(trans_p, py_states[1]);
    trans_p_dict['S'-'B'][0] = PyDict_GetItem(trans_p, py_states[3]);
    trans_p_dict['S'-'B'][1] = PyDict_GetItem(trans_p, py_states[2]);

    for(i=0;i<states_num;i++)
    {
        t_dict = PyDict_GetItem(emip_p, py_states[i]);
        t_double = MIN_FLOAT;
        ttemp = PySequence_GetItem(obs, 0);
        item = PyDict_GetItem(t_dict, ttemp);
        Py_DecRef(ttemp);
        if(item != NULL)
            t_double = PyFloat_AsDouble(item);
        t_double_2 = PyFloat_AsDouble(PyDict_GetItem(start_p, py_states[i]));
        V[0][states[i]-'B'] = t_double + t_double_2;
        path[0][states[i]-'B'] = states[i];
    }
    for(i=1;i<obs_len;i++)
    {
        t_obs = PySequence_GetItem(obs, i);
        for(j=0;j<states_num;j++)
        {
            em_p = MIN_FLOAT;
            y = states[j];
            item = PyDict_GetItem(emip_p_dict[j], t_obs);
            if(item != NULL)
                em_p = PyFloat_AsDouble(item);
            max_prob = MIN_FLOAT;
            best_state = '\0';
            for(p = 0; p < 2; p++)
            {
                prob = em_p;
                y0 = PrevStatus_str[y-'B'][p];
                prob += V[i - 1][y0-'B'];
                item = PyDict_GetItem(trans_p_dict[y-'B'][p], py_states[j]);
                if (item==NULL)
                    prob += MIN_FLOAT;
                else
                    prob += PyFloat_AsDouble(item);
                if (prob>max_prob)
                {
                    max_prob = prob;
                    best_state = y0;
                }
            }
            if(best_state == '\0')
            {
                for(p = 0; p < 2; p++)
                {
                    y0 = PrevStatus_str[y-'B'][p];
                    if(y0 > best_state)
                        best_state = y0;
                }
            }
            V[i][y-'B'] = max_prob;
            path[i][y-'B'] = best_state;
        }
        if(t_obs!=NULL)
            Py_DecRef(t_obs);
    }

    max_prob = V[obs_len-1]['E'-'B'];
    best_state = 'E';

    if (V[obs_len-1]['S'-'B'] > max_prob)
    {
        max_prob = V[obs_len-1]['S'-'B'];
        best_state = 'S';
    }

    res_tuple = PyTuple_New(2);
    PyTuple_SetItem(res_tuple, 0, PyFloat_FromDouble(max_prob));
    t_list = PyList_New(obs_len);
    now_state = best_state;

    for(i = obs_len - 1; i >= 0; i--)
    {
        PyList_SetItem(t_list, i, PyUnicode_FromStringAndSize(&now_state, 1));
        now_state = path[i][now_state-'B'];
    }

    PyTuple_SetItem(res_tuple, 1, t_list);
    free(V);
    free(path);

    Py_DecRef(py_states[0]);
    Py_DecRef(py_states[1]);
    Py_DecRef(py_states[2]);
    Py_DecRef(py_states[3]);
    return res_tuple;

}


%}

int _calc(PyObject* FREQ, PyObject* sentence,PyObject* DAG, PyObject * route, double total);
int _get_DAG(PyObject* DAG, PyObject* FREQ, PyObject* sentence);
int _get_DAG_and_calc(PyObject* FREQ, PyObject* sentence, PyObject * route, double total);
PyObject* _viterbi(PyObject* obs, PyObject* _states, PyObject* start_p, PyObject* trans_p, PyObject* emip_p);
